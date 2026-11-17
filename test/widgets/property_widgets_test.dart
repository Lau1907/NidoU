import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nidou/widgets/property_image.dart';

void main() {
  group('PropertyImage Widget Tests', () {
    const validBase64 =
        'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=';

    testWidgets('Renderiza widget Image con cadena Base64 válida sin excepciones',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PropertyImage(urls: [validBase64]),
          ),
        ),
      );

      // Debe encontrar al menos un widget Image
      expect(find.byType(Image), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'Renderiza fallback visual con icono de foto ante URL/lista vacía',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PropertyImage(urls: []),
          ),
        ),
      );

      expect(find.byIcon(Icons.photo), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'Constructor PropertyImage.single con string vacío muestra fallback visual',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PropertyImage.single(imageUrl: ''),
          ),
        ),
      );

      expect(find.byIcon(Icons.photo), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'Maneja string base64 malformado mostrando fallback sin lanzar excepción',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PropertyImage(urls: ['data:image/jpeg;base64,INVALID_BASE64_DATA']),
          ),
        ),
      );

      expect(find.byIcon(Icons.broken_image), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

