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

  static Future<void> UpdateGeofenceDataToDatabase({
    required String childName,
    required BuildContext Context,
    required String Datausername,
    required double Datalatitude,
    required double Datalongitude,
    required double Dataradius,
    required String DatastartTime,
    required String DataendTime,
    }) async {
    final url = Uri.parse(
        'https://childtrackr-backend-production.up.railway.app/geofence/data/${childName}');
    Map<String, String> headers = {'Content-Type': 'application/json'};
    http.Response response = await http.put(
    url,
    headers: headers,
    body: jsonEncode({
      'username': Datausername,
      'latitude': Datalatitude.toString(),
      'longitude': Datalongitude.toString(),
      'radius': Dataradius.toString(),
      'start_time': DatastartTime,
      'end_time': DataendTime,
    }),
  );

    if (response.statusCode == 200) {
      showDialog(
        context: Context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('Geofence Berhasil Disimpan'),
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
    } else if (response.statusCode == 404) {
      print(response.statusCode);
      showDialog(
        context: Context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Geofence Gagal Diupdate'),
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
            content: const Text('Terjadi Error Saat Update Geofence'),
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
    static Future<void> SaveNotificationToDatabase({
    required String childName,
    required BuildContext Context,
    required String Notifusername,
    required String Notifstatus,
    }) async {
    final url = Uri.parse(
        'https://childtrackr-backend-production.up.railway.app/notif/data');
    Map<String, String> headers = {'Content-Type': 'application/json'};
    http.Response response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'username': Notifusername,
        'status': Notifstatus,
      }),
    );

    if (response.statusCode == 201) {

    } else if (response.statusCode == 400) {
      print(response.statusCode);

    } else {

    }
  }

  static Future<void> SaveGeofenceHistoryToDatabase({
    required String childName,
    required BuildContext Context,
    required String Historyusername,
    required double Historylatitude,
    required double Historylongitude,
    required double Historyradius,
    required String HistorystartTime,
    required String HistoryendTime,
    }) async {
    final url = Uri.parse(
        'https://childtrackr-backend-production.up.railway.app/history/data');
    Map<String, String> headers = {'Content-Type': 'application/json'};
    http.Response response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'username': Historyusername,
        'latitude': Historylatitude.toString(),
        'longitude': Historylongitude.toString(),
        'radius': Historyradius.toString(),
        'start_time': HistorystartTime,
        'end_time': HistoryendTime,
      }),
    );

    if (response.statusCode == 201) {
      showDialog(
        context: Context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('Di Tambahkan ke History'),
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
            content: const Text('Gagal Menyimpan History'),
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
            content: const Text('Terjadi Error Saat Update History'),
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
