class Visit {
  final int? id;
  final String visitDate;
  final String visitTime;
  final String? gpsLocation;
  final double? latitude;
  final double? longitude;
  final String validationStatus;
  final int clientId;
  final int userId;
  final String? updatedAt;
  final int isSynced;

  Visit({
    this.id,
    required this.visitDate,
    required this.visitTime,
    this.gpsLocation,
    this.latitude,
    this.longitude,
    required this.validationStatus,
    required this.clientId,
    required this.userId,
    this.updatedAt,
    this.isSynced = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'visit_date': visitDate,
      'visit_time': visitTime,
      'gps_location': gpsLocation,
      'latitude': latitude,
      'longitude': longitude,
      'validation_status': validationStatus,
      'client_id': clientId,
      'user_id': userId,
      'updated_at': updatedAt,
      'is_synced': isSynced,
    };
  }

  factory Visit.fromMap(Map<String, dynamic> map) {
    return Visit(
      id: map['id'],
      visitDate: map['visit_date'],
      visitTime: map['visit_time'],
      gpsLocation: map['gps_location'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      validationStatus: map['validation_status'],
      clientId: map['client_id'],
      userId: map['user_id'],
      updatedAt: map['updated_at'],
      isSynced: map['is_synced'] ?? 0,
    );
  }
}