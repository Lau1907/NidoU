import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'views/firebase_test_view.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización del SDK de Firebase
  try {
    await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  } catch (e) {
    debugPrint(
      'Nota: Firebase.initializeApp requiere archivos de configuración '
      '(google-services.json para Android / GoogleService-Info.plist para iOS '
      'o DefaultFirebaseOptions creados con FlutterFire CLI). Error: $e',
    );
  }

  runApp(const NidoUApp());
}

class NidoUApp extends StatelessWidget {
  const NidoUApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NidoU',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterialDesign: true,
      ),
      home: const FirebaseTestView(),
    );
  }
}
