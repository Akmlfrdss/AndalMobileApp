// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:math' as math;
import 'geofencemaps.dart';
import 'package:http/http.dart' as http;
import 'api_utils.dart';

class ChildLocationMapPage extends StatefulWidget {
  final String childName;
  final double latitude;
  final double longitude;

  const ChildLocationMapPage({
    Key? key,
    required this.childName,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ChildLocationMapPageState createState() => _ChildLocationMapPageState();
}

class _ChildLocationMapPageState extends State<ChildLocationMapPage> {
  GoogleMapController? _mapController;
  LatLng _currentLocation = const LatLng(0, 0);
  LatLng? geofenceLocation;
  String _address = '';
  Set<Circle> _circles = {};
  TimeOfDay geofenceStartTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay geofenceEndTime = const TimeOfDay(hour: 0, minute: 0);
  bool _isLocationServiceEnabled = false;
  bool _isInsideGeofence = false;
  final StreamController<bool> _geofenceStreamController =
      StreamController<bool>.broadcast();
  Timer? _autoUpdateTimer;
  double _geofenceRadius = 100.0;

  @override
  void dispose() {
    _mapController?.dispose();
    _geofenceStreamController.close();
    _autoUpdateTimer!.cancel();
    super.dispose();
  }

  void initState() {
    super.initState();
    _getAddressFromCoordinates();
    _updateGeofenceStatus();
    isWithinGeofenceTime();

    if (isWithinGeofenceTime()) {
      _scheduleGeofenceDisplay();
    }

    _checkLocationPermissionStatus();
    _getDataFromDatabase();

    // Mulai timer otomatis untuk mengupdate lokasi setiap 5 detik
    _autoUpdateTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      print('Auto Update Timer Executed');
      if (_isLocationServiceEnabled) {
        print('Updating location');
        ApiUtils.getDataFromAPI(widget.childName, (location) {
          setState(() {
            _currentLocation = location;
          });
          print('Updated current location: $_currentLocation');
          _goToCurrentLocation();
        });
        _getAddressFromCoordinates();
        print('Updated geofence data: $geofenceLocation, $_geofenceRadius');
        _setGeofence(geofenceLocation!, _geofenceRadius);
        _checkGeofence();
        isWithinGeofenceTime();
        if (isWithinGeofenceTime()) {
          _scheduleGeofenceDisplay();
        }
        _updateGeofenceStatus();
        _getDataFromDatabase();
      }
    });
  }

  Future<void> _selectLocation() async {
    final TimeOfDay? selectedStartTime = await showTimePicker(
      context: context,
      initialTime: geofenceStartTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            colorScheme: const ColorScheme.light(primary: Colors.blue),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (selectedStartTime == null) {
      return;
    }

    final TimeOfDay? selectedEndTime = await showTimePicker(
      context: context,
      initialTime: geofenceEndTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            colorScheme: const ColorScheme.light(primary: Colors.blue),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (selectedEndTime == null) {
      return;
    }

    String formattedStartTime =
        '${selectedStartTime.hour.toString().padLeft(2, '0')}:${selectedStartTime.minute.toString().padLeft(2, '0')}';

    String formattedEndTime =
        '${selectedEndTime.hour.toString().padLeft(2, '0')}:${selectedEndTime.minute.toString().padLeft(2, '0')}';

    String UpdatedStartTime =
        '${selectedStartTime.hour.toString().padLeft(2, '0')}:${selectedStartTime.minute.toString().padLeft(2, '0')}';

    String UpdatedEndTime =
        '${selectedEndTime.hour.toString().padLeft(2, '0')}:${selectedEndTime.minute.toString().padLeft(2, '0')}';

    setState(() {
      geofenceStartTime = selectedStartTime;
      geofenceEndTime = selectedEndTime;
      _updateGeofenceStatus();
    });

    final LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GeofenceMapsPage(),
      ),
    );

    print('Selected Location: $selectedLocation');
    print('Geofence StartTime: $formattedStartTime');
    print('Geofence EndTime: $formattedEndTime');

    if (selectedLocation != null) {
      setState(() {
        geofenceLocation = selectedLocation;
        _setGeofence(selectedLocation, _geofenceRadius);
        _updateGeofenceStatus();
        if (isWithinGeofenceTime()) {
          _scheduleGeofenceDisplay();
        }
      });

      ApiUtils.UpdateGeofenceDataToDatabase(
        childName: widget.childName,
        Context: context,
        Datausername: widget.childName,
        Datalatitude: selectedLocation.latitude,
        Datalongitude: selectedLocation.longitude,
        Dataradius: _geofenceRadius,
        DatastartTime: UpdatedStartTime,
        DataendTime: UpdatedEndTime,
      );

      ApiUtils.SaveGeofenceHistoryToDatabase(
        childName: widget.childName,
        Context: context,
        Historyusername: widget.childName,
        Historylatitude: selectedLocation.latitude,
        Historylongitude: selectedLocation.longitude,
        Historyradius: _geofenceRadius,
        HistorystartTime: formattedStartTime,
        HistoryendTime: formattedEndTime,
      );
    }
  }

  Future<void> _getDataFromDatabase() async {
    final url = Uri.parse(
        'https://childtrackr-backend-production.up.railway.app/geofence/data'); // Ganti URL_ANDA sesuai dengan URL endpoint data geofence dari database Anda
    final response = await http.get(url);

    // print('Response status code: ${response.statusCode}');
    // print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      print(response.body);
      final List<dynamic> data = json.decode(response.body);
      final geofenceData = data.firstWhere(
          (geofencedata) => geofencedata['username'] == widget.childName,
          orElse: () => null);

      if (geofenceData != null) {
        double geofenceLatitude = geofenceData['latitude'];
        double geofenceLongitude = geofenceData['longitude'];
        String startTimeStr = geofenceData['start_time'];
        String endTimeStr = geofenceData['end_time'];

        TimeOfDay startTime = TimeOfDay(
          hour: int.parse(startTimeStr.split(':')[0]),
          minute: int.parse(startTimeStr.split(':')[1]),
        );

        TimeOfDay endTime = TimeOfDay(
          hour: int.parse(endTimeStr.split(':')[0]),
          minute: int.parse(endTimeStr.split(':')[1]),
        );
        // Set geofence berdasarkan data yang diambil dari database
        setState(() {
          geofenceLocation = LatLng(geofenceLatitude, geofenceLongitude);
          geofenceStartTime = startTime;
          geofenceEndTime = endTime;
        });
      }
    }
  }

  int compareTimeOfDay(TimeOfDay a, TimeOfDay b) {
    if (a.hour < b.hour) {
      return -1;
    } else if (a.hour > b.hour) {
      return 1;
    } else {
      return a.minute.compareTo(b.minute);
    }
  }

  bool isWithinGeofenceTime() {
    final currentTime = TimeOfDay.now();
    final startTime = TimeOfDay(
        hour: geofenceStartTime.hour, minute: geofenceStartTime.minute);
    final endTime =
        TimeOfDay(hour: geofenceEndTime.hour, minute: geofenceEndTime.minute);

    if (currentTime.hour >= startTime.hour && 
        currentTime.hour <= endTime.hour &&
        currentTime.minute >= startTime.minute &&
        currentTime.minute <= endTime.minute) {
      return true;
    } else {
      return false;
    }
  }

  void _scheduleGeofenceDisplay() {
    final currentTime = DateTime.now();

    final scheduledStartTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      geofenceStartTime.hour,
      geofenceStartTime.minute,
    );

    final scheduledEndTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      geofenceEndTime.hour,
      geofenceEndTime.minute,
    );

    final timeUntilStart = scheduledStartTime.difference(currentTime);
    final timeUntilEnd = scheduledEndTime.difference(currentTime);

    if (timeUntilStart.isNegative) {
      // The start time has already passed for today, schedule for tomorrow
      final scheduledDisplayTime =
          scheduledStartTime.add(const Duration(days: 1));
      _scheduleGeofenceNotification(scheduledDisplayTime);
    } else {
      _scheduleGeofenceNotification(scheduledStartTime);
    }

    if (timeUntilEnd.isNegative) {
      // The end time has already passed for today, schedule for tomorrow
      final scheduledCancelTime = scheduledEndTime.add(const Duration(days: 1));
      _cancelGeofenceNotification(scheduledCancelTime);
    } else {
      _cancelGeofenceNotification(scheduledEndTime);
    }
  }

  void _cancelGeofenceNotification(DateTime scheduledCancelTime) {
    // Mendapatkan ID notifikasi berdasarkan waktu yang akan dibatalkan
    int notificationId = scheduledCancelTime.millisecondsSinceEpoch;

    // Membatalkan notifikasi dengan menggunakan package flutter_local_notifications
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  void _scheduleGeofenceNotification(DateTime scheduledTime) {
    final Duration timeDifference = scheduledTime.difference(DateTime.now());

    Timer(timeDifference, () {
      showGeofenceLocation();
    });
  }

  void showGeofenceLocation() {
    // Display the geofence location on the map or perform any desired action
    // ignore: avoid_print
    print('Displaying geofence location: $geofenceLocation');
  }

  Future<void> _getAddressFromCoordinates() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentLocation.latitude,
        _currentLocation.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        String address = '${placemark.thoroughfare}, ${placemark.locality}';
        setState(() {
          _address = address;
        });
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  void _setGeofence(LatLng geofenceCenter, double radius) {
    setState(() {
      if (isWithinGeofenceTime()) {
        _circles = {
          Circle(
            circleId: const CircleId('geofence_circle'),
            center: geofenceCenter,
            radius: radius,
            fillColor: Colors.blue.withOpacity(0.2),
            strokeColor: Colors.blue,
            strokeWidth: 2,
          ),
        };
      } else {
        _circles =
            {}; // Jika tidak ada jadwal, lingkaran geofence tidak ditampilkan
      }
      geofenceLocation = geofenceCenter;
      radius = _geofenceRadius;
    });
  }

  void _checkGeofence() {
    if (geofenceLocation != null) {
      final distance = _calculateDistance(_currentLocation, geofenceLocation!);
      final radius = _geofenceRadius;
      bool isInside =
          distance <= radius && isWithinGeofenceTime(); // Perbarui kondisi
      setState(() {
        _isInsideGeofence = isInside;
      });
    }
  }

  // Menghitung jarak antara dua titik koordinat menggunakan formula Haversine
  double _calculateDistance(LatLng start, LatLng end) {
    const int earthRadius = 6371000; //meter
    double lat1Rad = start.latitude * math.pi / 180;
    double lat2Rad = end.latitude * math.pi / 180;
    double deltaLatRad = (end.latitude - start.latitude) * math.pi / 180;
    double deltaLngRad = (end.longitude - start.longitude) * math.pi / 180;

    double a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLngRad / 2) *
            math.sin(deltaLngRad / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    double distance = earthRadius.toDouble() * c;
    return distance;
  }

  void _updateGeofenceStatus() {
    _checkGeofence();
    _geofenceStreamController.add(_isInsideGeofence);
  }

  Future<void> _setMapStyle() async {
    String mapStyle = await rootBundle
        .loadString('assets/map_style.json'); // Memuat gaya peta dari file JSON
    _mapController?.setMapStyle(mapStyle);
  }

  void _goToCurrentLocation() {
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentLocation,
          zoom: 16.0,
        ),
      ));
    }
  }

  Future<void> _checkLocationPermissionStatus() async {
    var status = await Permission.locationWhenInUse.status;
    if (status.isGranted) {
      setState(() {
        _isLocationServiceEnabled = true;
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Lokasi Anak'),
        centerTitle: true,
        titleTextStyle: const TextStyle(fontFamily: 'LatoFont', fontSize: 25),
        backgroundColor: const Color(0xFF5863F8),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _setMapStyle();
              setState(() {
                _mapController = controller;
              });
            },
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 16.0,
            ),
            markers: <Marker>{
              Marker(
                markerId: const MarkerId('child_location'),
                position: _currentLocation,
                infoWindow: InfoWindow(
                  title: 'Lokasi Anak',
                  snippet: _address,
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueViolet,
                ),
              ),
            },
            circles: _circles,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 280,
              width: 500,
              decoration: BoxDecoration(
                color: const Color.fromARGB(
                    129, 73, 73, 73), // Mengatur transparansi di sini
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.8),
                    spreadRadius: 4,
                    blurRadius: 10,
                    offset: const Offset(0, 0),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 0.5,
                ),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 50.0, vertical: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 0),
                  Text(
                    'Nama Anak : ${widget.childName}',
                    style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    'Lokasi : $_address (${_currentLocation.latitude} ${_currentLocation.longitude})',
                    style: const TextStyle(
                        fontSize: 16.0,
                        color: Color.fromARGB(255, 165, 164, 164),
                        fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Jadwal : ${geofenceStartTime.format(context)} - ${geofenceEndTime.format(context)}',
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.normal,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  StreamBuilder<bool>(
                    stream: _geofenceStreamController.stream,
                    initialData: false,
                    builder: (context, snapshot) {
                      bool isInside = snapshot.data ?? false;
                      String geofenceStatus =
                          isInside ? 'Di Dalam Area.' : 'Di Luar Area. ';
                      Color textColor = isInside
                          ? Colors.green
                          : const Color.fromARGB(255, 255, 36, 20);
                      // ignore: unrelated_type_equality_checks
                      if (!isInside && !isWithinGeofenceTime()) {
                        geofenceStatus = 'Tidak Ada Jadwal.';
                        textColor = Colors.grey;
                      }

                      return RichText(
                        text: TextSpan(
                          text: ' Status Lokasi : ',
                          style: const TextStyle(
                            fontSize: 17.0,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w900,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                          children: [
                            TextSpan(
                              text: geofenceStatus,
                              style: TextStyle(
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _selectLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5863F8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      shadowColor: const Color.fromARGB(255, 0, 0, 0)
                          .withOpacity(1), // Menambahkan warna bayangan
                      elevation: 6, // Menambahkan tinggi bayangan
                    ),
                    child: const Text(
                      ('Pilih Koordinat Geofence'),
                      style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
