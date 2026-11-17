import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nidou/utils/universities.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedUniversity;
  String _userRole = '';

  // Colors from the palette
  static const _terracotta = Color(0xFFB85042);
  static const _sand = Color(0xFFE7E8D1);
  static const _sage = Color(0xFFA7BEAE);
  static const _textColor = Color(0xFF3A2E2A);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data() ?? {};
    _nameController.text = data['name'] ?? data['nombre'] ?? '';
    _phoneController.text = data['phone']?.toString() ?? data['telefono']?.toString() ?? '';
    _userRole = (data['role'] ?? '').toString().toUpperCase();
    _selectedUniversity = data['university'] as String? ?? defaultUniversity;

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _saveChanges() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final updateData = <String, dynamic>{
      'name': _nameController.text,
      'nombre': _nameController.text,
      'phone': _phoneController.text,
      'telefono': _phoneController.text,
    };
    if (_userRole == 'ESTUDIANTE' && _selectedUniversity != null) {
      updateData['university'] = _selectedUniversity;
    }
    await docRef.set(updateData, SetOptions(merge: true));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cambios guardados')),
      );
    }
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.black26),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _terracotta, width: 2),
    );

    final isStudent = _userRole == 'ESTUDIANTE';

    return Scaffold(
      backgroundColor: _sand,
      appBar: AppBar(
        backgroundColor: _terracotta,
        foregroundColor: Colors.white,
        title: const Text('Mi perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar with initial
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: _sage,
                child: Text(
                  uid.isNotEmpty ? uid[0].toUpperCase() : '',
                  style: const TextStyle(fontSize: 40, color: _textColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Role chip (we fetch it lazily from Firestore)
            Center(
              child: FutureBuilder<DocumentSnapshot>(
                future: uid.isNotEmpty ? FirebaseFirestore.instance.collection('users').doc(uid).get() : null,
                builder: (context, snapshot) {
                  String role = '';
                  if (snapshot.hasData && snapshot.data?.data() != null) {
                    role = (snapshot.data?.get('role') ?? '').toString().toUpperCase();
                  }
                  if (role.isEmpty) return const SizedBox.shrink();
                  return Chip(
                    label: Text(role, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    backgroundColor: _terracotta,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // Email display
            Center(
              child: Text(
                FirebaseAuth.instance.currentUser?.email ?? '',
                style: const TextStyle(color: _textColor, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 24),
            // Editable fields
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre',
                labelStyle: const TextStyle(color: _textColor),
                filled: true,
                fillColor: Colors.white,
                border: inputBorder,
                enabledBorder: inputBorder,
                focusedBorder: focusedBorder,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Teléfono / WhatsApp',
                labelStyle: const TextStyle(color: _textColor),
                filled: true,
                fillColor: Colors.white,
                border: inputBorder,
                enabledBorder: inputBorder,
                focusedBorder: focusedBorder,
              ),
              keyboardType: TextInputType.phone,
            ),
            if (isStudent) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: universities.containsKey(_selectedUniversity) ? _selectedUniversity : defaultUniversity,
                decoration: InputDecoration(
                  labelText: '¿A qué universidad asistes?',
                  labelStyle: const TextStyle(color: _textColor),
                  filled: true,
                  fillColor: Colors.white,
                  border: inputBorder,
                  enabledBorder: inputBorder,
                  focusedBorder: focusedBorder,
                ),
                dropdownColor: Colors.white,
                isExpanded: true,
                items: universities.keys.map((univ) {
                  return DropdownMenuItem<String>(
                    value: univ,
                    child: Text(
                      univ,
                      style: const TextStyle(fontSize: 13, color: _textColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedUniversity = val);
                  }
                },
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB85042),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Guardar cambios', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _signOut,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFB85042),
                side: const BorderSide(color: Color(0xFFB85042), width: 1.5),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cerrar sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
