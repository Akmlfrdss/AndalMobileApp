import 'dart:convert';
import 'package:flutter/material.dart';
import 'childlocation.dart';
import 'maps.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'childprofiles.dart';
import 'package:http/http.dart' as http;

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

  @override
  void initState() {
    super.initState();
    _getChildProfiles();
  }

  Future<void> _getChildProfiles() async {
    try {
      final profiles = await _fetchChildProfiles();
      setState(() {
        childProfiles = profiles;
      });
    } catch (error) {
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
    final url = Uri.parse('http://10.0.2.2:3000/childProfiles');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      final List<ChildProfile> childProfiles = responseData
          .map((data) => ChildProfile(
                username: data['username'],
                name: data['name'],
                latitude: data['latitude'],
                longitude: data['longitude'],
              ))
          .toList();
      _getChildProfiles();
      return childProfiles; 
    } else {
      throw Exception('Gagal mengambil data Child Profile.');
    }
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
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF5863F8), Color(0xFF5FBFF9)],
              begin: Alignment.centerRight,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
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
                        fontFamily: 'LatoFont',
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 50.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  Expanded(
                    child: ListView.builder(
                      itemCount: childProfiles.length,
                      itemBuilder: (context, index) {
                        if (childProfiles[index].username == widget.username) {
                          return ChildProfileButton(
                            childProfile: childProfiles[index],
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChildLocationMapPage(
                                    childName: childProfiles[index].name,
                                    latitude: childProfiles[index].latitude,
                                    longitude: childProfiles[index].longitude,
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
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryPage(username: widget.username),
                ),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(username: widget.username),
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
        floatingActionButton: FloatingActionButton(
          onPressed: _addProfile,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _addProfile() async {
    final LatLng? selectedLatLng = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MapPage(),
      ),
    );

    if (selectedLatLng != null) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) {
          String name = '';
          double latitude = selectedLatLng.latitude;
          double longitude = selectedLatLng.longitude;

          return AlertDialog(
            title: const Text('Tambah Profil Anak'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    name = value;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Nama Anak',
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Koordinat Terpilih: ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final newProfile = ChildProfile(
                    username: widget.username,
                    name: name,
                    latitude: latitude,
                    longitude: longitude,
                  );
                  _saveChildProfile(newProfile);
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
    }
  }

  Future<void> _saveChildProfile(ChildProfile newProfile) async {
    String username = newProfile.username;
    String name = newProfile.name;
    double latitude = newProfile.latitude;
    double longitude = newProfile.longitude;
    Uri url = Uri.parse('http://10.0.2.2:3000/addProfile');
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


class HistoryPage extends StatelessWidget {
  final String username;

  const HistoryPage({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: const Center(
        child: Text('Halaman History'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ParentHomePage(username: username),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(username: username),
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
