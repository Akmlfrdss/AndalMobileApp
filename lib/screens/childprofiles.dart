import 'package:flutter/material.dart';

class ChildProfile {
  final String username;
  final String name;
  final double latitude;
  final double longitude;

  ChildProfile({
    required this.username,
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

class ChildProfileButton extends StatelessWidget {
  final ChildProfile childProfile;
  final VoidCallback onPressed;
  

  const ChildProfileButton({
    Key? key,
    required this.childProfile,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 40.0, vertical: 20.0), // Menambahkan jarak kiri dan kanan
      child: SizedBox(
        width: 50.0,
        height: 120.0,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 253, 252, 252),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            shadowColor:
                Colors.black.withOpacity(1), // Menambahkan warna bayangan
            elevation: 3, // Menambahkan tinggi bayangan
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.child_care, size: 30, color: Color(0xFF5863F8)),
              const SizedBox(height: 8.0, width: 2.0),
              Text(
                childProfile.name,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF5863F8)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
