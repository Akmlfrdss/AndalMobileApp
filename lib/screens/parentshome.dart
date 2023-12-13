import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'childlocation.dart';
import 'childprofiles.dart';
import 'package:http/http.dart' as http;
import 'parents_login.dart';
import 'package:tracking_loc2/main.dart';
import 'parenthistory.dart';

class ParentHomePage extends StatefulWidget {
  final String username;

  const ParentHomePage({Key? key, required this.username}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ParentHomePageState createState() => _ParentHomePageState();
}

class _ParentHomePageState extends State<ParentHomePage> {
  int _currentIndex = 0;
  List<ChildProfile> childProfiles = [];
  // ignore: unused_field
  bool _isLocationServiceEnabled = false;

  @override
  void initState() {
    super.initState();
    _getChildProfiles();
    _requestLocationPermission();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Buka Pengaturan',
          onPressed: () {
            openAppSettings();
          },
        ),
      ),
    );
  }

  Future<void> _requestLocationPermission() async {
    // Minta izin lokasi "ACCESS_FINE_LOCATION".
    var status = await Permission.locationAlways.request();
    if (status.isGranted) {
      
      setState(() {
        _isLocationServiceEnabled = true;
      });
    } else {
      // Handle jika izin lokasi tidak diberikan.
      // Tampilkan pesan kepada pengguna dan beri tahu cara memberikan izin melalui pengaturan perangkat.
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Izin Lokasi Diperlukan'),
          content: Text(
              'Aplikasi memerlukan izin lokasi untuk berfungsi dengan baik. Silakan berikan izin melalui pengaturan perangkat.'),
          actions: [
            TextButton(
              onPressed: () {
                openAppSettings();
              },
              child: Text('Buka Pengaturan'),
            ),
          ],
        ),
      );
    }
  }

  void _addChildProfile(ChildProfile newProfile) {
    setState(() {
      childProfiles.add(newProfile);
    });
  }

  Future<void> _getChildProfiles() async {
    try {
      final profiles = await _fetchChildProfiles();
      setState(() {
        childProfiles = profiles;
      });
    } catch (error) {
      print('error =${error}');
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

  Future<List<ChildProfile>> _fetchChildProfiles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? getToken = prefs.getString('getToken');
    final url = Uri.parse(
        'https://childtrackr-backend-production.up.railway.app/user/userProfiles');
    final headers = {'Authorization': '${getToken}'};
    final response = await http.get(url, headers: headers);

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}'); // Print the response body

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      final List<ChildProfile> childProfiles = responseData
          .map((data) => ChildProfile(
                username: data['username'],
                name: data['name'],
                latitude:
                    data['latitude'].toString(), // Ubah tipe data ke double
                longitude: data['longitude'].toString(),
              ))
          .toList();
      return childProfiles;
    } else {
      throw Exception('');
    }
  }

  void _goToLandingPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ParentLoginPage(), // Replace with the appropriate registration page
      ),
    );
  }

  void _logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('userType');
    prefs.remove('username');
    prefs.remove('getToken');

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
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF5863F8), Color(0xFF5FBFF9)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48.0),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        'Hi, ${widget.username}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Goldplay',
                          color: Color(0xFF5FBFF9),
                          fontSize: 40.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        'Selamat datang di Andal',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Goldplay',
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 20.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 0.0),
                      child: Text(
                        '#AnakDalamLindungan',
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontFamily: 'LatoFont',
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 13.0,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 150, // Adjust the height as needed
                        padding: const EdgeInsets.symmetric(horizontal: 100.0),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(0, 250, 250, 250),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(40.0),
                            topRight: Radius.circular(40.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment
                              .spaceBetween, // Align buttons evenly
                          children: [
                            Container(
                              width: 60.0, // Adjust button width as needed
                              height: 60.0,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HistoryPage(
                                          username: widget.username),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.white,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.history,
                                      size: 25,
                                      color: Color.fromARGB(255, 31, 31, 31),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 60.0, // Adjust button width as needed
                              height: 60.0,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProfilePage(
                                          username: widget.username),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.white,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      size: 25,
                                      color: Color.fromARGB(255, 31, 31, 31),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  height: 320,
                  width: 500,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(
                        160, 250, 250, 250), // Mengatur transparansi di sini
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      topRight: Radius.circular(15.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF5863F8).withOpacity(1),
                        spreadRadius: 3,
                        blurRadius: 1.5,
                        offset: const Offset(1, 1),
                      ),
                    ],
                    border: Border.all(
                      color: Color.fromARGB(230, 0, 0, 0).withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40.0, vertical: 20.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 0),
                        Text(
                          'Daftar Anak',
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 17.0,
                              fontWeight: FontWeight.w900,
                              color: Color.fromARGB(255, 24, 24, 24)),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: childProfiles.length,
                            itemBuilder: (context, index) {
                              if (childProfiles[index].username ==
                                  widget.username) {
                                return ChildProfileButton(
                                  childProfile: childProfiles[index],
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ChildLocationMapPage(
                                          childName: childProfiles[index].name,
                                          latitude: double.parse(
                                              childProfiles[index].latitude),
                                          longitude: double.parse(
                                              childProfiles[index].latitude),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return const SizedBox();
                              }
                            },
                          ),
                        ),
                      ])),
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
        floatingActionButton: FloatingActionButton(
          onPressed: _addProfile,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _getCoordinatesByUsername(
      String username) async {
    final url = Uri.parse(
        'https://childtrackr-backend-production.up.railway.app/child/findCoordinates');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'username': username});

    print('Sending request to: $url with body: $body');

    final response = await http.post(url, body: body, headers: headers);

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['latitude'] != null &&
          responseData['longitude'] != null) {
        return {
          'childUsername': responseData['username'],
          'latitude': responseData['latitude'].toString(),
          'longitude': responseData['longitude'].toString(),
        };
      } else {
        throw Exception('Data koordinat tidak ditemukan.');
      }
    } else {
      throw Exception('Gagal mengambil data koordinat.');
    }
  }

  void _addProfile() async {
    String childUsername = '';
    String latitude = ''.toString();
    String longitude = ''.toString();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Tambah Profil Anak'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      childUsername = value;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Username Anak',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        final coordinates =
                            await _getCoordinatesByUsername(childUsername);
                        setState(() {
                          latitude = coordinates['latitude'] ?? 0.0;
                          longitude = coordinates['longitude'] ?? 0.0;
                        });
                      } catch (error) {
                        // Tangani error jika ada masalah dalam permintaan http
                        print('Error: $error');
                      }
                    },
                    child: const Text('Dapatkan Info'),
                  ),
                  const SizedBox(height: 10.0),
                  Text('Username: $childUsername'),
                  Text(
                      'Latitude: ${latitude}'), // Tampilkan dengan format yang diinginkan
                  Text(
                      'Longitude: ${longitude}'), // Tampilkan dengan format yang diinginkan
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    final newProfile = ChildProfile(
                      username: widget.username,
                      name: childUsername,
                      latitude: latitude,
                      longitude: longitude,
                    );
                    _saveChildProfile(newProfile);
                    _addChildProfile(newProfile);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Simpan'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Batal'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveChildProfile(ChildProfile newProfile) async {
    String username = newProfile.username;
    String name = newProfile.name;
    String latitude = newProfile.latitude;
    String longitude = newProfile.longitude;
    Uri url = Uri.parse(
        'https://childtrackr-backend-production.up.railway.app/user/addProfile');
    Map<String, String> headers = {'Content-Type': 'application/json'};
    var body = ({
      'username': username,
      'name': name,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
    });

    try {
      http.Response response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Sukses'),
              content: const Text('Profil berhasil dibuat'),
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
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Gagal menyimpan profil'),
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
    } catch (error) {
      // ignore: avoid_print
      print('Error: $error');
    }
  }
}

class ProfilePage extends StatelessWidget {
  final String username;

  const ProfilePage({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: const Center(
        child: Text('Halaman Profil'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ParentHomePage(username: username),
              ),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HistoryPage(username: username),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
