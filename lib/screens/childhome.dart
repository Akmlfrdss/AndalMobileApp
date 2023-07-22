import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  final LatLng _currentLocation =
      const LatLng(37.42796133580664, -122.085749655962);

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _getAddressFromCoordinates() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentLocation.latitude,
        -_currentLocation.longitude,
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
  
  Future<void> _setMapStyle() async {
    String mapStyle = await rootBundle
        .loadString('assets/map_style.json'); // Memuat gaya peta dari file JSON
    _mapController?.setMapStyle(mapStyle);
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
          ),
        ],
      ),
    );
  }
}
