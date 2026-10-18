class AppUser {
  final String id;
  final String name;
  final String email;
  final String role; // 'estudiante' o 'arrendador'

  static const String roleEstudiante = 'estudiante';
  static const String roleArrendador = 'arrendador';

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  bool get isEstudiante => role == roleEstudiante;
  bool get isArrendador => role == roleArrendador;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map, {String? id}) {
    return AppUser(
      id: id ?? (map['id'] as String? ?? ''),
      name: (map['name'] as String? ?? ''),
      email: (map['email'] as String? ?? ''),
      role: (map['role'] as String? ?? roleEstudiante),
    );
  }

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          role == other.role;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ email.hashCode ^ role.hashCode;

  @override
  String toString() => 'AppUser(id: $id, name: $name, email: $email, role: $role)';
}

/// Alias para mantener retrocompatibilidad si es necesario
typedef User = AppUser;
