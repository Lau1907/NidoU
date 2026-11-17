import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nidou/models/property.dart';
import 'package:nidou/repositories/property_repository.dart';
import 'package:nidou/viewmodels/publish_property_viewmodel.dart';

// ignore: subtype_of_sealed_class
class FakeDocumentSnapshot extends Fake
    implements DocumentSnapshot<Map<String, dynamic>> {
  final Map<String, dynamic> _data;
  @override
  final String id;

  FakeDocumentSnapshot(this._data, {this.id = 'doc_test_1'});

  @override
  Map<String, dynamic>? data() => _data;
}

class MockPropertyRepository extends PropertyRepository {
  Property? lastSavedProperty;
  bool shouldThrow = false;

  @override
  Future<Property> createProperty(Property property) async {
    if (shouldThrow) {
      throw Exception('Fallo simulado al guardar en Firestore');
    }
    lastSavedProperty = property.copyWith(
      id: 'mock_prop_123',
    );
    return lastSavedProperty!;
  }
}

void main() {
  group('Property Model Tests', () {
    test('Crea una instancia completa de Property', () {
      final now = DateTime(2026, 10, 18, 12, 0);
      final property = Property(
        id: 'prop-1',
        title: 'Habitación luminosa en campus',
        price: 3200.50,
        distanceMinutes: 10,
        type: Property.typeHabitacion,
        location: 'Av. Universidad 123',
        description: 'Incluye servicios y baño privado',
        services: const ['agua', 'internet', 'luz'],
        photos: const ['https://example.com/foto1.jpg'],
        ownerId: 'owner-99',
        createdAt: now,
      );

      expect(property.id, 'prop-1');
      expect(property.title, 'Habitación luminosa en campus');
      expect(property.price, 3200.50);
      expect(property.distanceMinutes, 10);
      expect(property.type, 'habitacion');
      expect(property.location, 'Av. Universidad 123');
      expect(property.description, 'Incluye servicios y baño privado');
      expect(property.services, ['agua', 'internet', 'luz']);
      expect(property.photos, ['https://example.com/foto1.jpg']);
      expect(property.ownerId, 'owner-99');
      expect(property.createdAt, now);
    });

    test('Serialización toMap contiene todos los campos requeridos', () {
      final now = DateTime(2026, 10, 18);
      final property = Property(
        id: 'prop-2',
        title: 'Departamento compartido',
        price: 4500.0,
        distanceMinutes: 15,
        type: Property.typeDepartamento,
        location: 'Calle Roble 45',
        description: 'Excelente ambiente estudiantil',
        services: const ['agua', 'internet', 'amueblado', 'luz', 'lavandería'],
        photos: const [
          'https://example.com/1.jpg',
          'https://example.com/2.jpg'
        ],
        ownerId: 'owner-101',
        createdAt: now,
      );

      final map = property.toMap();
      expect(map['title'], 'Departamento compartido');
      expect(map['price'], 4500.0);
      expect(map['distanceMinutes'], 15);
      expect(map['type'], 'departamento');
      expect(map['location'], 'Calle Roble 45');
      expect(map['description'], 'Excelente ambiente estudiantil');
      expect(map['services'],
          ['agua', 'internet', 'amueblado', 'luz', 'lavandería']);
      expect(map['photos'],
          ['https://example.com/1.jpg', 'https://example.com/2.jpg']);
      expect(map['ownerId'], 'owner-101');
      expect(map['createdAt'], isA<Timestamp>());
    });

    test(
        'fromMap es tolerante a campos faltantes y lee price como (num).toDouble()',
        () {
      final mapWithIntPrice = {
        'title': 'Estudio individual',
        'price': 2800, // int numérico
        // faltan distanceMinutes, type, location, description, services, photos, ownerId, createdAt
      };

      final property = Property.fromMap(mapWithIntPrice, id: 'prop-3');
      expect(property.id, 'prop-3');
      expect(property.title, 'Estudio individual');
      expect(property.price, 2800.0);
      expect(property.distanceMinutes, 0);
      expect(property.type, 'habitacion');
      expect(property.location, '');
      expect(property.description, '');
      expect(property.services, isEmpty);
      expect(property.photos, isEmpty);
      expect(property.ownerId, '');
      expect(property.createdAt, isA<DateTime>());
    });

    test('fromMap maneja price nulo sin lanzar excepción', () {
      final mapWithoutPrice = <String, dynamic>{
        'title': 'Sin precio especificado',
      };

      final property = Property.fromMap(mapWithoutPrice, id: 'prop-4');
      expect(property.price, 0.0);
    });

    test('fromFirestore deserializa correctamente desde un DocumentSnapshot',
        () {
      final now = DateTime(2026, 10, 18, 10, 0);
      final fakeDoc = FakeDocumentSnapshot({
        'title': 'Habitación con balcón',
        'price': 3900.5,
        'distanceMinutes': 8,
        'type': 'habitacion',
        'location': 'Calle Juárez 50',
        'description': 'Vista exterior',
        'services': ['agua', 'internet'],
        'photos': ['https://example.com/foto.jpg'],
        'ownerId': 'owner-abc',
        'createdAt': Timestamp.fromDate(now),
      }, id: 'doc-firestore-1');

      final property = Property.fromFirestore(fakeDoc);
      expect(property.id, 'doc-firestore-1');
      expect(property.title, 'Habitación con balcón');
      expect(property.price, 3900.5);
      expect(property.distanceMinutes, 8);
      expect(property.type, 'habitacion');
      expect(property.location, 'Calle Juárez 50');
      expect(property.description, 'Vista exterior');
      expect(property.services, ['agua', 'internet']);
      expect(property.photos, ['https://example.com/foto.jpg']);
      expect(property.ownerId, 'owner-abc');
      expect(property.createdAt, now);
    });
  });

  group('PublishPropertyViewModel Tests', () {
    late MockPropertyRepository mockRepo;
    late PublishPropertyViewModel viewModel;

    setUp(() {
      mockRepo = MockPropertyRepository();
      viewModel = PublishPropertyViewModel(propertyRepository: mockRepo);
    });

    test('Estado inicial es correcto', () {
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.photoUrls, isEmpty);
    });

    test('addPhotoUrl valida que la URL comience con https://', () {
      // Intento con URL vacía
      final emptyResult = viewModel.addPhotoUrl('');
      expect(emptyResult, isFalse);
      expect(viewModel.errorMessage, contains('enlace'));

      // Intento con http:// (no permitido)
      final httpResult = viewModel.addPhotoUrl('http://inseguro.com/foto.jpg');
      expect(httpResult, isFalse);
      expect(viewModel.errorMessage, contains('https://'));

      // Éxito con https://
      final httpsResult =
          viewModel.addPhotoUrl('https://seguro.com/foto.jpg');
      expect(httpsResult, isTrue);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.photoUrls.length, 1);
    });

    test('addPhotoUrl respeta límite máximo de 3 fotos', () {
      expect(viewModel.addPhotoUrl('https://ejemplo.com/1.jpg'), isTrue);
      expect(viewModel.addPhotoUrl('https://ejemplo.com/2.jpg'), isTrue);
      expect(viewModel.addPhotoUrl('https://ejemplo.com/3.jpg'), isTrue);
      expect(viewModel.photoUrls.length, 3);

      // Intento de agregar una 4ta foto
      final fourthResult =
          viewModel.addPhotoUrl('https://ejemplo.com/4.jpg');
      expect(fourthResult, isFalse);
      expect(viewModel.errorMessage, contains('máximo de 3'));
      expect(viewModel.photoUrls.length, 3);
    });

    test('removePhotoUrl elimina fotos por índice', () {
      viewModel.addPhotoUrl('https://ejemplo.com/1.jpg');
      viewModel.addPhotoUrl('https://ejemplo.com/2.jpg');

      viewModel.removePhotoUrl(0);
      expect(viewModel.photoUrls.length, 1);
      expect(viewModel.photoUrls.first, 'https://ejemplo.com/2.jpg');
    });

    test('Validación falla si el título está vacío', () async {
      viewModel.addPhotoUrl('https://ejemplo.com/1.jpg');
      final result = await viewModel.publish(
        title: '   ',
        price: 3000,
        location: 'Centro',
        ownerId: 'owner-1',
      );

      expect(result, isFalse);
      expect(viewModel.errorMessage, isNotNull);
      expect(viewModel.errorMessage, contains('título'));
      expect(mockRepo.lastSavedProperty, isNull);
    });

    test('Validación falla si el precio es nulo, cero o negativo', () async {
      viewModel.addPhotoUrl('https://ejemplo.com/1.jpg');

      final resultZero = await viewModel.publish(
        title: 'Habitación Centro',
        price: 0,
        location: 'Centro',
        ownerId: 'owner-1',
      );
      expect(resultZero, isFalse);
      expect(viewModel.errorMessage, contains('precio'));

      final resultNeg = await viewModel.publish(
        title: 'Habitación Centro',
        price: -500,
        location: 'Centro',
        ownerId: 'owner-1',
      );
      expect(resultNeg, isFalse);
      expect(viewModel.errorMessage, contains('precio'));
    });

    test('Validación falla si la ubicación está vacía', () async {
      viewModel.addPhotoUrl('https://ejemplo.com/1.jpg');

      final result = await viewModel.publish(
        title: 'Habitación Centro',
        price: 2500,
        location: '   ',
        ownerId: 'owner-1',
      );

      expect(result, isFalse);
      expect(viewModel.errorMessage, contains('ubicación'));
    });

    test('Validación falla si no hay al menos una foto (URL)', () async {
      final result = await viewModel.publish(
        title: 'Habitación Centro',
        price: 2500,
        location: 'Av. Hidalgo 100',
        ownerId: 'owner-1',
      );

      expect(result, isFalse);
      expect(viewModel.errorMessage, contains('foto'));
    });

    test('Publish exitoso guarda la propiedad con las URLs y limpia fotos',
        () async {
      viewModel.addPhotoUrl('https://servidor.com/propiedad1.jpg');
      viewModel.addPhotoUrl('https://servidor.com/propiedad2.jpg');

      final success = await viewModel.publish(
        title: 'Departamento amueblado',
        price: '4200.00',
        distanceMinutes: 12,
        type: Property.typeDepartamento,
        location: 'Calle Magnolia 88',
        description: 'Todo incluido',
        services: ['agua', 'internet', 'luz'],
        ownerId: 'owner-xyz',
      );

      expect(success, isTrue);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.photoUrls, isEmpty);

      expect(mockRepo.lastSavedProperty, isNotNull);
      expect(mockRepo.lastSavedProperty!.title, 'Departamento amueblado');
      expect(mockRepo.lastSavedProperty!.price, 4200.0);
      expect(mockRepo.lastSavedProperty!.photos.length, 2);
      expect(mockRepo.lastSavedProperty!.photos[0],
          'https://servidor.com/propiedad1.jpg');
      expect(mockRepo.lastSavedProperty!.photos[1],
          'https://servidor.com/propiedad2.jpg');
    });

    test('Publish maneja errores del repositorio y establece errorMessage',
        () async {
      mockRepo.shouldThrow = true;
      viewModel.addPhotoUrl('https://servidor.com/foto.jpg');

      final success = await viewModel.publish(
        title: 'Estudio cerca de facultad',
        price: 3100,
        location: 'Av. Universidad 500',
        ownerId: 'owner-xyz',
      );

      expect(success, isFalse);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNotNull);
      expect(viewModel.errorMessage, contains('error'));
    });
  });
}
