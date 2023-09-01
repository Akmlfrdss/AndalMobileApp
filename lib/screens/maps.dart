// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';

// class MapPage extends StatefulWidget {
//   const MapPage({Key? key}) : super(key: key);

//   @override
//   _MapPageState createState() => _MapPageState();
// }

// class _MapPageState extends State<MapPage> {
//   GoogleMapController? _controller;
//   LatLng? _selectedLatLng;
//   Set<Marker> _markers = {};

//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     _controller = controller;
//   }

//   void _getCurrentLocation(BuildContext context) async {
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         // Permission still denied, show error message or handle accordingly
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       // Permission denied forever, show error message or handle accordingly
//       return;
//     }

//     if (permission == LocationPermission.whileInUse ||
//         permission == LocationPermission.always) {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       LatLng latLng = LatLng(position.latitude, position.longitude);
//       setState(() {
//         _selectedLatLng = latLng;
//         _markers = {
//           Marker(
//             markerId: const MarkerId('selected_location'),
//             position: _selectedLatLng!,
//           ),
//         };
//       });
//       _moveToLocation(latLng);
//     }
//   }

//   void _moveToLocation(LatLng latLng) {
//     _controller?.animateCamera(CameraUpdate.newLatLng(latLng));
//   }

//   void _onConfirm() {
//     if (_selectedLatLng != null) {
//       Navigator.pop(context, _selectedLatLng);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Koordinat Anak'),
//         actions: [
//           IconButton(
//             onPressed: _onConfirm,
//             icon: const Icon(Icons.check),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: GoogleMap(
//               onMapCreated: _onMapCreated,
//               initialCameraPosition: CameraPosition(
//                 target: _selectedLatLng ?? const LatLng(-6.1754, 106.8272),
//                 zoom: 15.0,
//               ),
//               onTap: (LatLng tapLatLng) {
//                 setState(() {
//                   _selectedLatLng = tapLatLng;
//                   _markers = {
//                     Marker(
//                       markerId: const MarkerId('selected_location'),
//                       position: _selectedLatLng!,
//                     ),
//                   };
//                 });
//               },
//               markers: _markers,
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _getCurrentLocation(context),
//         child: const Icon(Icons.my_location),
//       ),
//     );
//   }
// }
