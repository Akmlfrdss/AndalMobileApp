import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tracking_loc2/screens/notifhistory.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


class historyNotifPage extends StatefulWidget {
  final String username;

  historyNotifPage({Key? key, required this.username}) : super(key: key);

  @override
  _HistoryNotifState createState() => _HistoryNotifState();
}

class _HistoryNotifState extends State<historyNotifPage> {
  List<ChildNotifHistory> notifHistorys = [];

  @override
  void initState() {
    super.initState();
    _getChildHistory();
  }

  Future<void> _getChildHistory() async {
    try {
      final notifs = await _fetchChildHistory();
      setState(() {
        notifHistorys = notifs.cast<ChildNotifHistory>() ;
      });
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

  Future<List<ChildNotifHistory>> _fetchChildHistory() async {
    final url = Uri.parse(
        'https://childtrackr-backend-production.up.railway.app/notif/data');
    final response = await http.get(url);

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      final List<ChildNotifHistory> notifHistorys = responseData
          .map((data) => ChildNotifHistory(
                childUsername: data['username'],
                status: data['status'],
                date: data['createdAt'],
              ))
          .toList();
      return notifHistorys;
    } else {
      throw Exception('');
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
      body: Stack(
        children: [
            ListView.builder(
            itemCount: notifHistorys.length,
            itemBuilder: (context, index) {
              // Tampilkan informasi history di sini
            final history = notifHistorys[index];
            String dateString = history.date; // Assuming date is in string format
            
            // Konversi waktu ke GMT+7
            String gmt7Time = convertToGMT7(dateString);
              return ListTile(
                title: Text('${history.childUsername}',
                style: TextStyle(
                  fontSize: 18.0,
                fontWeight: FontWeight.w600),
                ),
                subtitle:   Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text('Status Lokasi: ${history.status}'),
                  ],
                ),
                trailing: Text('$gmt7Time'),
                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              );
            },
          ),
        ]
      ),
    );
  }
}
