import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:nidou/models/property.dart';
import 'package:nidou/utils/universities.dart';

void main() {
  group('Universities and Walking Minutes Logic Tests', () {
    test('universities contiene las 7 instituciones de Dolores Hidalgo', () {
      final expectedUniversities = [
        'UTNG - Universidad Tecnológica del Norte de Guanajuato',
        'UDHI - Universidad Dolores Hidalgo',
        'Universidad Patria (Dolores Hidalgo)',
        'Universidad de León (Plantel Dolores Hidalgo)',
        'UPN - Universidad Pedagógica Nacional (Unidad 111)',
        'UICEG - Instituto Universitario del Centro de México',
        'CEDHI - Centro de Estudios Dolores Hidalgo',
      ];

      expect(universities.length, 7);
      for (final univ in expectedUniversities) {
        expect(universities.containsKey(univ), isTrue,
            reason: 'Debe contener $univ');
        expect(universities[univ], isNotNull);
        expect(universities[univ]!.latitude, isNotNull);
        expect(universities[univ]!.longitude, isNotNull);
      }
    });

    test('defaultUniversity existe en el mapa de universidades', () {
      expect(universities.containsKey(defaultUniversity), isTrue);
      expect(defaultUniversity,
          'UTNG - Universidad Tecnológica del Norte de Guanajuato');
    });

    test('calculateWalkingMinutes a 0 metros devuelve 1 (mínimo clamp)', () {
      const origin = LatLng(21.1669, -100.9317);
      const dest = LatLng(21.1669, -100.9317);

      final minutes = calculateWalkingMinutes(origin, dest);
      expect(minutes, 1);
    });

    test(
        'calculateWalkingMinutes a distancia cercana (~800 m) devuelve entre 10 y 15 min',
        () {
      // Coordenadas con ~800 metros de distancia
      const origin = LatLng(21.1669, -100.9317);
      // Desplazamiento aproximado de ~0.0072 grados de latitud (~800m)
      const dest = LatLng(21.1741, -100.9317);

      final minutes = calculateWalkingMinutes(origin, dest);
      expect(minutes, greaterThanOrEqualTo(10));
      expect(minutes, lessThanOrEqualTo(15));
    });

    test(
        'calculateWalkingMinutes a distancia muy lejana devuelve 180 (máximo clamp)',
        () {
      // Coordenadas de Dolores Hidalgo a Tokio o Ciudad de México (~250+ km)
      const origin = LatLng(21.1669, -100.9317);
      const farAway = LatLng(19.4326, -99.1332); // CDMX

      final minutes = calculateWalkingMinutes(origin, farAway);
      expect(minutes, 180);
    });
  });

  group('Property Model Serialization & Deserialization Tests', () {
    test(
        'fromMap y toMap soportan fotos URL y fotos Base64, coordenadas y valores por defecto',
        () {
      const base64Photo =
          'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAP...';
      const urlPhoto = 'https://example.com/propiedad.jpg';

      final map = <String, dynamic>{
        'title': 'Estudio amplio amueblado',
        'price': 3500.0,
        'distanceMinutes': 12,
        'type': 'estudio',
        'location': 'Av. Dolores 200, Centro',
        'description': 'Estudio independiente con todos los servicios',
        'services': ['Agua', 'Luz', 'Internet', 'Amueblado'],
        'photos': [base64Photo, urlPhoto],
        'ownerId': 'owner_456',
        'university': 'UTNG - Universidad Tecnológica del Norte de Guanajuato',
        'latitude': 21.1675,
        'longitude': -100.9320,
        'createdAt': Timestamp.fromDate(DateTime(2026, 11, 15, 10, 30)),
      };

      final property = Property.fromMap(map, id: 'prop_test_123');

      expect(property.id, 'prop_test_123');
      expect(property.title, 'Estudio amplio amueblado');
      expect(property.price, 3500.0);
      expect(property.distanceMinutes, 12);
      expect(property.type, 'estudio');
      expect(property.location, 'Av. Dolores 200, Centro');
      expect(property.description,
          'Estudio independiente con todos los servicios');
      expect(property.services, ['Agua', 'Luz', 'Internet', 'Amueblado']);
      expect(property.photos.length, 2);
      expect(property.photos[0], base64Photo);
      expect(property.photos[1], urlPhoto);
      expect(property.ownerId, 'owner_456');
      expect(property.university,
          'UTNG - Universidad Tecnológica del Norte de Guanajuato');
      expect(property.latitude, 21.1675);
      expect(property.longitude, -100.9320);

      // Serializar a Map
      final serialized = property.toMap();
      expect(serialized['title'], 'Estudio amplio amueblado');
      expect(serialized['price'], 3500.0);
      expect(serialized['distanceMinutes'], 12);
      expect(serialized['type'], 'estudio');
      expect(serialized['location'], 'Av. Dolores 200, Centro');
      expect(serialized['photos'], [base64Photo, urlPhoto]);
      expect(serialized['ownerId'], 'owner_456');
      expect(serialized['university'],
          'UTNG - Universidad Tecnológica del Norte de Guanajuato');
      expect(serialized['latitude'], 21.1675);
      expect(serialized['longitude'], -100.9320);
      expect(serialized['createdAt'], isA<Timestamp>());
    });

    test('fromMap asigna valores por defecto seguros ante campos ausentes o nulos',
        () {
      final minimalMap = <String, dynamic>{
        'title': 'Cuarto básico',
      };

      final property = Property.fromMap(minimalMap, id: 'prop_min');

      expect(property.id, 'prop_min');
      expect(property.title, 'Cuarto básico');
      expect(property.price, 0.0);
      expect(property.distanceMinutes, 0);
      expect(property.type, 'habitacion');
      expect(property.location, '');
      expect(property.description, '');
      expect(property.services, isEmpty);
      expect(property.photos, isEmpty);
      expect(property.ownerId, '');
      expect(property.university, isNull);
      expect(property.latitude, isNull);
      expect(property.longitude, isNull);
      expect(property.createdAt, isA<DateTime>());
    });
  });
}

