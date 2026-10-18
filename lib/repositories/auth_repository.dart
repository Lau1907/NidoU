import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../models/user.dart';

class AuthRepository {
  final fb_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    fb_auth.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? fb_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Stream de cambios de estado de autenticación en Firebase
  Stream<fb_auth.User?> get authStateChanges => _auth.authStateChanges();

  /// Usuario actual de Firebase Auth
  fb_auth.User? get currentFirebaseUser => _auth.currentUser;

  /// Inicia sesión con correo electrónico y contraseña
  Future<AppUser?> signIn({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    if (userCredential.user != null) {
      return await getCurrentUserProfile();
    }
    return null;
  }

  /// Registra un nuevo usuario en Firebase Auth y crea su documento en Firestore.
  /// No guarda la contraseña en ningún lado.
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw Exception('No fue posible crear la cuenta de usuario');
    }

    // Actualiza el nombre en Firebase Auth si está disponible
    if (name.trim().isNotEmpty) {
      await firebaseUser.updateDisplayName(name.trim());
    }

    final appUser = AppUser(
      id: firebaseUser.uid,
      name: name.trim(),
      email: email.trim(),
      role: role,
    );

    // Guarda el documento en la colección "users" de Firestore sin la contraseña
    await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .set(appUser.toMap());

    return appUser;
  }

  /// Cierra la sesión activa
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Lee el perfil del usuario actual desde la colección "users" de Firestore
  Future<AppUser?> getCurrentUserProfile() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    final docSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();

    if (docSnapshot.exists && docSnapshot.data() != null) {
      return AppUser.fromMap(docSnapshot.data()!, id: docSnapshot.id);
    }

    // Si aún no existe el documento en Firestore, devuelve un perfil base
    return AppUser(
      id: currentUser.uid,
      name: currentUser.displayName ?? '',
      email: currentUser.email ?? '',
      role: AppUser.roleEstudiante,
    );
  }
}
