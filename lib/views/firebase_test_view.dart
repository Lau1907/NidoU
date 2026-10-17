import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class FirebaseTestView extends StatefulWidget {
  const FirebaseTestView({super.key});

  @override
  State<FirebaseTestView> createState() => _FirebaseTestViewState();
}

class _FirebaseTestViewState extends State<FirebaseTestView> {
  bool _isLoading = false;
  String? _statusMessage;
  bool _isSuccess = false;

  Future<void> _testFirestoreConnection() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
      _isSuccess = false;
    });

    try {
      // Verificar si Firebase app ha sido inicializada
      if (Firebase.apps.isEmpty) {
        throw Exception(
          'Firebase no está inicializado. Asegúrate de configurar '
          'google-services.json (Android) o GoogleService-Info.plist (iOS).',
        );
      }

      // Intentar escribir un documento de prueba en la colección 'test_connection'
      final testDoc = FirebaseFirestore.instance
          .collection('test_connection')
          .doc('status_check');

      await testDoc.set({
        'lastChecked': FieldValue.serverTimestamp(),
        'status': 'Connection successful',
        'appName': 'NidoU',
      });

      // Intentar leer el documento recién guardado
      final snapshot = await testDoc.get();

      if (snapshot.exists) {
        final data = snapshot.data();
        setState(() {
          _isSuccess = true;
          _statusMessage =
              '¡Conexión exitosa a Firestore!\nDocumento leído correctamente: $data';
        });
      } else {
        setState(() {
          _isSuccess = false;
          _statusMessage =
              'Se envió el documento pero no se pudo recuperar de Firestore.';
        });
      }
    } catch (e) {
      setState(() {
        _isSuccess = false;
        _statusMessage = 'Error al conectar con Firebase/Firestore:\n$e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NidoU - Prueba Firebase'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  size: 80,
                  color: Colors.deepOrangeAccent,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Prueba de Conexión Firestore',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Presiona el botón para intentar escribir y leer un documento de prueba en Firestore.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testFirestoreConnection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.sync_rounded),
                  label: Text(
                    _isLoading ? 'Verificando...' : 'Probar Conexión Firestore',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 32),
                if (_statusMessage != null)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _isSuccess
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isSuccess
                            ? Colors.green.shade400
                            : Colors.red.shade400,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _isSuccess
                              ? Icons.check_circle_rounded
                              : Icons.error_outline_rounded,
                          color: _isSuccess ? Colors.green : Colors.red,
                          size: 44,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _statusMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _isSuccess
                                ? Colors.green.shade900
                                : Colors.red.shade900,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
