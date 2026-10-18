import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'theme/app_colors.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/login_view.dart';
import 'views/property_search_view.dart';

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

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: const NidoUApp(),
    ),
  );
}

class NidoUApp extends StatelessWidget {
  const NidoUApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NidoU',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.arena,
        colorScheme: const ColorScheme.light(
          primary: AppColors.terracota,
          secondary: AppColors.salvia,
          surface: AppColors.arena,
          onPrimary: AppColors.blanco,
          onSurface: AppColors.texto,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.arena,
          foregroundColor: AppColors.texto,
          elevation: 0,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

/// Controla la pantalla visible según el estado de la sesión
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    // Muestra pantalla de carga mientras Firebase verifica si hay sesión guardada
    if (!authVM.isInitialized) {
      return const Scaffold(
        backgroundColor: AppColors.arena,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.terracota,
          ),
        ),
      );
    }

    // Si hay usuario autenticado, muestra la vista principal (PropertySearchView);
    // de lo contrario, muestra LoginView.
    if (authVM.isAuthenticated) {
      return const PropertySearchView();
    }

    return const LoginView();
  }
}
