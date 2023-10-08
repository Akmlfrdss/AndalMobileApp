import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracking_loc2/main.dart';


class ChildHomePage extends StatefulWidget {
  final String username;

  const ChildHomePage({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  _ChildHomePageState createState() => _ChildHomePageState();
}

class _ChildHomePageState extends State<ChildHomePage> {
  GoogleMapController? _mapController;
  String _address = '';
  LatLng _currentLocation = LatLng(37.42796133580664, -122.085749655962);
  bool _isLocationServiceEnabled = false;

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _setMapStyle(); // Load map style when map is created
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Buka Pengaturan',
          onPressed: () {
            // Open device settings to allow location permission
            openAppSettings();
          },
        ),
      ),
    );
  }

  Timer? _updateTimer, _autoUpdateTimer;
  @override
  void initState() {
    super.initState();
    _checkLocationPermissionStatus();
    _getCurrentLocation();
    // Mulai timer dengan interval 1 detik
    _updateTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      print('Timer Executed');
      if (_isLocationServiceEnabled) {
        print('Sending data to backend');
        _sendDataToBackend(
            _currentLocation.latitude, _currentLocation.longitude);
      }
    });

    // Mulai timer otomatis untuk mengupdate lokasi setiap 1 detik
    _autoUpdateTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      print('Auto Update Timer Executed');
      if (_isLocationServiceEnabled) {
        print('Updating location');
        _goToCurrentLocation();
        _getCurrentLocation();
      }
    });
  }

  @override
  void dispose() {
    _updateTimer!.cancel();
    _autoUpdateTimer!.cancel();
    super.dispose();
  }

  Future<void> _checkLocationPermissionStatus() async {
    var status = await Permission.locationWhenInUse.status;
    if (status.isGranted) {
      setState(() {
        _isLocationServiceEnabled = true;
      });
    }
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
        if (address != _address) {
          setState(() {
            _address = address;
          });
        }
      }
    } catch (e) {
      print("Error getting address: $e");
    }
  }

  Future<void> _setMapStyle() async {
    try {
      String mapStyle = await rootBundle.loadString('assets/map_style.json');
      _mapController?.setMapStyle(mapStyle);
    } catch (e) {
      print("Error loading map style: $e");
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLocationServiceEnabled = true;
      });
      await _getAddressFromCoordinates();
    } catch (e) {
      print("Error getting current location: $e");
      _showSnackBar(
          'Izin akses lokasi tidak diberikan. Aktifkan izin lokasi pada pengaturan perangkat.');
    }
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

  Future<void> _sendDataToBackend(double latitude, double longitude) async {
    try {
      final response = await http.put(
        Uri.parse(
            'https://childtrackr-backend-production.up.railway.app/child/findCoordinates/${widget.username}'), // Ganti dengan URL backend Anda
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': widget.username,
          'latitude': latitude,
          'longitude': longitude
        }),
      );

      if (response.statusCode == 200) {
        print('Coordinate sent successfully');
      } else {
        print('Failed to send coordinate');
      }
    } catch (e) {
      print('Error sending coordinate: $e');
    }
  }

  void _logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('userType');
    prefs.remove('username');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            LandingPage(), // Ganti dengan halaman login yang sesuai
      ),
    );
  }

  Future<void> _confirmLogout() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Log Out'),
          content: Text('Apakah Anda yakin ingin keluar?'),
          actions: <Widget>[
            TextButton(
              child: Text('Tidak'),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
            ),
            TextButton(
              child: Text('Ya'),
              onPressed: () {
                _logOut(); // Panggil fungsi log out saat tombol "Ya" ditekan
                Navigator.of(context).pop(); // Tutup dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
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
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 16.0,
            ),
            markers: {
              if (_isLocationServiceEnabled)
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
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: _isLocationServiceEnabled
                  ? () {
                      _goToCurrentLocation();
                      _sendDataToBackend(_currentLocation.latitude,
                          _currentLocation.longitude);
                    }
                  : null,
              child: Icon(Icons.my_location),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.logout_outlined),
                onPressed: _confirmLogout,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
