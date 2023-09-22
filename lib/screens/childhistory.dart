class ChildHistory {
  final String childName;
  final double latitude;
  final double longitude;
  final String startTime;
  final String endTime;
  final String date;
  String address;

  ChildHistory({
    required this.childName,
    required this.latitude,
    required this.longitude,
    required this.startTime,
    required this.endTime,
    required this.date,
    this.address = 'Mengambil alamat...', // Default value while fetching
  });
} 