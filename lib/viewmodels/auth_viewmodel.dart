import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../models/user.dart';
import '../repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AppUser? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  StreamSubscription<fb_auth.User?>? _authSubscription;

  AuthViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository() {
    _initAuthListener();
  }

  // Getters de estado
  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;

  void _initAuthListener() {
    _authSubscription = _authRepository.authStateChanges.listen((fbUser) async {
      if (fbUser != null) {
        // Carga el perfil desde Firestore para mantener sesión persistente
        try {
          _user = await _authRepository.getCurrentUserProfile();
        } catch (e) {
          debugPrint('Error al recuperar perfil de usuario: $e');
        }
      } else {
        _user = null;
      }
      _isInitialized = true;
      notifyListeners();
    });
  }

  /// Limpia cualquier mensaje de error existente
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Inicia sesión con correo y contraseña
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authRepository.signIn(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _mapFirebaseError(e);
      notifyListeners();
      return false;
    }
  }

  /// Registra un nuevo usuario con rol ("estudiante" o "arrendador")
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authRepository.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _mapFirebaseError(e);
      notifyListeners();
      return false;
    }
  }

  /// Cierra la sesión activa
  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.signOut();
      _user = null;
    } catch (e) {
      _errorMessage = _mapFirebaseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Traduce los errores de Firebase a mensajes amigables en español
  String _mapFirebaseError(dynamic error) {
    if (error is fb_auth.FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'El correo electrónico no es válido.';
        case 'wrong-password':
          return 'Contraseña incorrecta.';
        case 'user-not-found':
          return 'No existe una cuenta registrada con este correo.';
        case 'invalid-credential':
          return 'Correo o contraseña incorrectos.';
        case 'email-already-in-use':
          return 'Este correo electrónico ya está registrado.';
        case 'weak-password':
          return 'La contraseña es muy débil. Debe tener al menos 6 caracteres.';
        case 'network-request-failed':
          return 'Sin conexión a internet. Verifica tu red.';
        case 'too-many-requests':
          return 'Demasiados intentos fallidos. Inténtalo más tarde.';
        case 'user-disabled':
          return 'Esta cuenta ha sido inhabilitada.';
        case 'operation-not-allowed':
          return 'El inicio de sesión no está habilitado actualmente.';
        default:
          return error.message ?? 'Ocurrió un error inesperado. Intenta de nuevo.';
      }
    } else if (error is SocketException) {
      return 'Sin conexión a internet. Verifica tu red.';
    }

    final message = error.toString();
    if (message.contains('network') || message.contains('SocketException')) {
      return 'Sin conexión a internet. Verifica tu red.';
    }

    return 'Ocurrió un error inesperado. Intenta nuevamente.';
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
