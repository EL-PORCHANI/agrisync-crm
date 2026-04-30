class Zone {
  final int? id;
  final String name;
  final String? description;

  Zone({
    this.id,
    required this.name,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  factory Zone.fromMap(Map<String, dynamic> map) {
    return Zone(
      id: map['id'],
      name: map['name'],
      description: map['description'],
    );
  }
}