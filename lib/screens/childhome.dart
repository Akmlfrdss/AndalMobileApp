import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

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

  @override
  void initState() {
    super.initState();
    _checkLocationPermissionStatus();
    _getCurrentLocation();
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
        desiredAccuracy: LocationAccuracy.high,
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
  try{
  final response = await http.post(
    Uri.parse('http://192.168.100.4:3000/coordinates'), // Ganti dengan URL backend Anda
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
  }
   catch (e) {
      print('Error sending coordinate: $e');
  }
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
                  ?() {
                      _goToCurrentLocation();
                      _sendDataToBackend(
                      _currentLocation.latitude, _currentLocation.longitude);
                    }
                  : null,
              child: Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}

