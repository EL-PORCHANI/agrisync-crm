class Client {
  final int? id;
  final String name;
  final String? phone;
  final String? address;
  final String? gpsLocation;
  final double? latitude;
  final double? longitude;
  final String? pricingCategory;
  final int zoneId;
  final String? updatedAt;
  final int isSynced;

  Client({
    this.id,
    required this.name,
    this.phone,
    this.address,
    this.gpsLocation,
    this.latitude,
    this.longitude,
    this.pricingCategory,
    required this.zoneId,
    this.updatedAt,
    this.isSynced = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'gps_location': gpsLocation,
      'latitude': latitude,
      'longitude': longitude,
      'pricing_category': pricingCategory,
      'zone_id': zoneId,
      'updated_at': updatedAt,
      'is_synced': isSynced,
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      address: map['address'],
      gpsLocation: map['gps_location'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      pricingCategory: map['pricing_category'],
      zoneId: map['zone_id'],
      updatedAt: map['updated_at'],
      isSynced: map['is_synced'] ?? 0,
    );
  }
}