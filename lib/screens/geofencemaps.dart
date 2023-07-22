import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class GeofenceMapsPage extends StatefulWidget {
  const GeofenceMapsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GeofenceMapsPageState createState() => _GeofenceMapsPageState();
}


class _GeofenceMapsPageState extends State<GeofenceMapsPage> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  final TextEditingController _searchController = TextEditingController();
  Set<Marker> _markers = {};

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

    void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _setMapStyle();
  }


  Future<void> _searchLocation(String query) async {
    if (query.isNotEmpty) {
      try {
        List<Location> locations = await locationFromAddress(query);
        if (locations.isNotEmpty) {
          Location location = locations.first;
          setState(() {
            _selectedLocation = LatLng(location.latitude, location.longitude);
            _markers = <Marker>{
              Marker(
                markerId: const MarkerId('geofence_marker'),
                position: _selectedLocation!,
              ),
            };
          });
          _moveToLocation(_selectedLocation!);
        }
      // ignore: empty_catches
      } catch (e) {
      }
    }
  }

  void _moveToLocation(LatLng location) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location,
          zoom: 15.0,
        ),
      ),
    );
  }

    Future<void> _setMapStyle() async {
    String mapStyle = await rootBundle.loadString('assets/map_style.json'); // Memuat gaya peta dari file JSON
    _mapController?.setMapStyle(mapStyle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi Geofence'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Cari Lokasi',
                      suffixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (value) {
                      _searchLocation(value);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _markers.clear();
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(-6.1754, 106.8272),
                zoom: 15.0,
              ),
              onTap: (position) {
                setState(() {
                  _selectedLocation = position;
                  _markers = <Marker>{
                    Marker(
                      markerId: const MarkerId('geofence_marker'),
                      position: _selectedLocation!,
                    ),
                  };
                });
              },
              markers: _markers,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context, _selectedLocation);
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
