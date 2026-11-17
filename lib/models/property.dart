import 'package:cloud_firestore/cloud_firestore.dart';

class Property {
  final String id;
  final String title;
  final double price;
  final int distanceMinutes;
  final String type; // "habitacion", "departamento" o "estudio"
  final String location;
  final String description;
  final List<String> services;
  final List<String> photos;
  final String ownerId;
  final DateTime createdAt;

  static const String typeHabitacion = 'habitacion';
  static const String typeDepartamento = 'departamento';
  static const String typeEstudio = 'estudio';

  const Property({
    required this.id,
    required this.title,
    required this.price,
    required this.distanceMinutes,
    required this.type,
    required this.location,
    required this.description,
    required this.services,
    required this.photos,
    required this.ownerId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'distanceMinutes': distanceMinutes,
      'type': type,
      'location': location,
      'description': description,
      'services': services,
      'photos': photos,
      'ownerId': ownerId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Property.fromMap(Map<String, dynamic> data, {String? id}) {
    return Property(
      id: id ?? (data['id'] as String? ?? ''),
      title: data['title'] as String? ?? '',
      price: data['price'] != null ? (data['price'] as num).toDouble() : 0.0,
      distanceMinutes: data['distanceMinutes'] != null
          ? (data['distanceMinutes'] as num).toInt()
          : 0,
      type: data['type'] as String? ?? typeHabitacion,
      location: data['location'] as String? ?? '',
      description: data['description'] as String? ?? '',
      services: (data['services'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      photos: (data['photos'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      ownerId: data['ownerId'] as String? ?? '',
      createdAt: _parseDateTime(data['createdAt']),
    );
  }

  factory Property.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Property(
      id: doc.id,
      title: data['title'] as String? ?? '',
      price: data['price'] != null ? (data['price'] as num).toDouble() : 0.0,
      distanceMinutes: data['distanceMinutes'] != null
          ? (data['distanceMinutes'] as num).toInt()
          : 0,
      type: data['type'] as String? ?? typeHabitacion,
      location: data['location'] as String? ?? '',
      description: data['description'] as String? ?? '',
      services: (data['services'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      photos: (data['photos'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      ownerId: data['ownerId'] as String? ?? '',
      createdAt: _parseDateTime(data['createdAt']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.now();
  }

  Property copyWith({
    String? id,
    String? title,
    double? price,
    int? distanceMinutes,
    String? type,
    String? location,
    String? description,
    List<String>? services,
    List<String>? photos,
    String? ownerId,
    DateTime? createdAt,
  }) {
    return Property(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      distanceMinutes: distanceMinutes ?? this.distanceMinutes,
      type: type ?? this.type,
      location: location ?? this.location,
      description: description ?? this.description,
      services: services ?? this.services,
      photos: photos ?? this.photos,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
