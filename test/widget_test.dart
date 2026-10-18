import 'package:flutter_test/flutter_test.dart';
import 'package:nidou/models/user.dart';

void main() {
  group('AppUser Model Tests', () {
    test('Crea una instancia correcta de AppUser', () {
      const user = AppUser(
        id: '12345',
        name: 'Carlos Ruiz',
        email: 'carlos@test.com',
        role: AppUser.roleEstudiante,
      );

      expect(user.id, '12345');
      expect(user.name, 'Carlos Ruiz');
      expect(user.email, 'carlos@test.com');
      expect(user.role, 'estudiante');
      expect(user.isEstudiante, isTrue);
      expect(user.isArrendador, isFalse);
    });

    test('Serialización toMap y deserialización fromMap', () {
      final map = {
        'id': '67890',
        'name': 'Ana Gómez',
        'email': 'ana@arrendador.com',
        'role': AppUser.roleArrendador,
      };

      final user = AppUser.fromMap(map);
      expect(user.id, '67890');
      expect(user.name, 'Ana Gómez');
      expect(user.email, 'ana@arrendador.com');
      expect(user.role, 'arrendador');
      expect(user.isArrendador, isTrue);
      expect(user.isEstudiante, isFalse);

      final serialized = user.toMap();
      expect(serialized['id'], '67890');
      expect(serialized['name'], 'Ana Gómez');
      expect(serialized['email'], 'ana@arrendador.com');
      expect(serialized['role'], 'arrendador');
      // Aseguramos que la contraseña NUNCA forme parte de la estructura
      expect(serialized.containsKey('password'), isFalse);
    });

    test('copyWith preserva valores no alterados', () {
      const user = AppUser(
        id: 'u1',
        name: 'Laura',
        email: 'laura@nido.com',
        role: AppUser.roleEstudiante,
      );

      final updated = user.copyWith(name: 'Laura Sofia');
      expect(updated.id, 'u1');
      expect(updated.name, 'Laura Sofia');
      expect(updated.email, 'laura@nido.com');
      expect(updated.role, 'estudiante');
    });
  });
}
