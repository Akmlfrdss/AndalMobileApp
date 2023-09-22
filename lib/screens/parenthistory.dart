import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:tracking_loc2/screens/childhistory.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  final String username;

  HistoryPage({Key? key, required this.username}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<ChildHistory> childHistorys = [];

  @override
  void initState() {
    super.initState();
    _getChildHistory();
  }

  Future<void> _getChildHistory() async {
    try {
      final profiles = await _fetchChildHistory();
      setState(() {
        childHistorys = profiles ;
      });
      for (var history in childHistorys) {
        await _getAddressFromCoordinates(history);
      }
    } catch (error) {
      print('Error fetching child history: $error');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Gagal mengambil data Child Profile'),
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

  Future<List<ChildHistory>> _fetchChildHistory() async {
    final url = Uri.parse(
        'https://childtrackr-backend-production.up.railway.app/history/data');
    final response = await http.get(url);

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      final List<ChildHistory> childHistorys = responseData
          .map((data) => ChildHistory(
                childName: data['username'],
                latitude: double.parse(data['latitude'].toString()),
                longitude: double.parse(data['longitude'].toString()),
                startTime: data['start_time'],
                endTime: data['end_time'],
                date: data['createdAt'],
                address: '',
              ))
          .toList();
      return childHistorys;
    } else {
      throw Exception('');
    }
  }

  Future<void> _getAddressFromCoordinates(ChildHistory history) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          history.latitude, history.longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        String address = '${placemark.thoroughfare}, ${placemark.locality}';
        setState(() {
          history.address = address; // Mengatur alamat pada objek ChildHistory
        });
      }
    } catch (e) {
      print('Error getting address: $e');
    }
  }

  String convertToGMT7(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString).add(Duration(hours: 7));
    String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        centerTitle: true,
        titleTextStyle: const TextStyle(fontFamily: 'LatoFont', fontSize: 25),
        backgroundColor: const Color(0xFF5863F8),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: childHistorys.length,
          itemBuilder: (context, index) {
            // Tampilkan informasi history di sini
          final history = childHistorys[index];
          String dateString = history.date; // Assuming date is in string format
          
          // Konversi waktu ke GMT+7
          String gmt7Time = convertToGMT7(dateString);
            return ListTile(
              title: Text('${history.childName}',
              style: TextStyle(
                fontSize: 18.0,
               fontWeight: FontWeight.w600),
              ),
              subtitle:   Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text('Alamat: ${history.address}'),
                Text('Jam: ${history.startTime} - ${history.endTime}'),
                ],
              ),
              trailing: Text('$gmt7Time'),
              contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            );
          },
        ),
      ),
    );
  }
}
