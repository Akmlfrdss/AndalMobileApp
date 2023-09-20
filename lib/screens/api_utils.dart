import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ApiUtils {
  static Future<void> getDataFromAPI(
    String childName,
    Function(LatLng) updateLocation,
  ) async {
    final url = Uri.parse(
        'https://childtrackr-backend-production.up.railway.app/child/findCoordinates');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final profile = data.firstWhere(
          (profile) => profile['username'] == childName,
          orElse: () => null);

      if (profile != null) {
        double childlatitude = profile['latitude'];
        double childlongitude = profile['longitude'];
        LatLng location = LatLng(childlatitude, childlongitude);
        updateLocation(location);
      }
    }
  }

    static Future<void> saveGeofenceDataToDatabase({
    required BuildContext Context,
    required String Datausername,
    required double Datalatitude,
    required double Datalongitude,
    required double Dataradius,
    required TimeOfDay DatastartTime,
    required TimeOfDay DataendTime,
    }) async {
    final url = Uri.parse(
        'https://childtrackr-backend-production.up.railway.app/geofence/data');
    Map<String, String> headers = {'Content-Type': 'application/json'};
    http.Response response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'username': Datausername,
        'latitude': Datalatitude.toString(),
        'longitude': Datalongitude.toString(),
        'radius': Dataradius.toString(),
        'start_time': '${DatastartTime.hour}:${DatastartTime.minute}',
        'end_time': '${DataendTime.hour}:${DataendTime.minute}',
      }),
    );

    if (response.statusCode == 201) {
      showDialog(
        context: Context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('Data Berhasil Terupdate'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    } else if (response.statusCode == 400) {
      print(response.statusCode);
      showDialog(
        context: Context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Semua Data Harus Terisi'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: Context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Data Gagal Diupdate'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }

  static Future<void> getAddressFromCoordinates(
    LatLng currentLocation,
    Function(String) updateAddress,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        currentLocation.latitude,
        currentLocation.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        String address = '${placemark.thoroughfare}, ${placemark.locality}';
        updateAddress(address);
      }
    } catch (e) {}
  }
}
