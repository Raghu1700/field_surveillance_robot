class LandmineDetection {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  LandmineDetection({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory LandmineDetection.fromMap(Map<String, dynamic> map) {
    return LandmineDetection(
      latitude: map['latitude'],
      longitude: map['longitude'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
