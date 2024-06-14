class SOSData {
  double latitude;
  double longitude;
  DateTime time;

  SOSData({
    required this.latitude,
    required this.longitude,
    required this.time,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'time': time,
    };
  }
}
