import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nidou/utils/universities.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _careerController = TextEditingController();
  final _scheduleController = TextEditingController();

  String? _selectedUniversity;
  String _userRole = '';
  String? _photoBase64;
  int _favoritesCount = 0;
  int _myPropertiesCount = 0;
  bool _isLoading = true;

  // Colors from the NidoU palette
  static const _terracotta = Color(0xFFB85042);
  static const _sand = Color(0xFFE7E8D1);
  static const _sage = Color(0xFFA7BEAE);
  static const _textColor = Color(0xFF3A2E2A);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _careerController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }

  Uint8List? _getPhotoBytes(String? base64Str) {
    if (base64Str == null || base64Str.isEmpty) return null;
    try {
      final clean = base64Str.contains(',') ? base64Str.split(',').last : base64Str;
      return base64Decode(clean);
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data() ?? {};
      _nameController.text = data['name'] ?? data['nombre'] ?? '';
      _phoneController.text = data['phone']?.toString() ?? data['telefono']?.toString() ?? '';
      _bioController.text = data['bio']?.toString() ?? '';
      _careerController.text = data['career']?.toString() ?? '';
      _scheduleController.text = data['schedule']?.toString() ?? '';
      _userRole = (data['role'] ?? '').toString().toUpperCase();
      _selectedUniversity = data['university'] as String? ?? defaultUniversity;
      _photoBase64 = data['photoBase64'] as String?;

      final favs = data['favorites'];
      if (favs is List) {
        _favoritesCount = favs.length;
      }

      if (_userRole == 'ARRENDADOR') {
        final propSnap = await FirebaseFirestore.instance
            .collection('properties')
            .where('ownerId', isEqualTo: uid)
            .get();
        _myPropertiesCount = propSnap.docs.length;
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 40,
        maxWidth: 400,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        if (mounted) {
          setState(() {
            _photoBase64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final updateData = <String, dynamic>{
      'name': _nameController.text.trim(),
      'nombre': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'telefono': _phoneController.text.trim(),
      'bio': _bioController.text.trim(),
    };
    if (_photoBase64 != null) {
      updateData['photoBase64'] = _photoBase64;
    }
    if (_userRole == 'ESTUDIANTE') {
      if (_selectedUniversity != null) {
        updateData['university'] = _selectedUniversity;
      }
      updateData['career'] = _careerController.text.trim();
    } else if (_userRole == 'ARRENDADOR') {
      updateData['schedule'] = _scheduleController.text.trim();
    }

    try {
      await docRef.set(updateData, SetOptions(merge: true));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cambios guardados')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
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
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.black26),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _terracotta, width: 2),
    );

    final isStudent = _userRole == 'ESTUDIANTE';
    final isLandlord = _userRole == 'ARRENDADOR';
    final photoBytes = _getPhotoBytes(_photoBase64);
    final initial = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()[0].toUpperCase()
        : (FirebaseAuth.instance.currentUser?.email?.isNotEmpty == true
            ? FirebaseAuth.instance.currentUser!.email![0].toUpperCase()
            : 'U');

    return Scaffold(
      backgroundColor: _sand,
      appBar: AppBar(
        backgroundColor: _terracotta,
        foregroundColor: Colors.white,
        title: const Text('Mi perfil'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Interactive avatar with floating camera badge
                  Center(
                    child: Stack(
                      children: [
                        InkWell(
                          onTap: _pickImage,
                          borderRadius: BorderRadius.circular(60),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: _terracotta, width: 3),
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: _sage,
                              backgroundImage: photoBytes != null ? MemoryImage(photoBytes) : null,
                              child: photoBytes == null
                                  ? Text(
                                      initial,
                                      style: const TextStyle(
                                        fontSize: 40,
                                        color: _textColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: _terracotta,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Role chip
                  if (_userRole.isNotEmpty)
                    Center(
                      child: Chip(
                        label: Text(
                          _userRole,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: _terracotta,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  const SizedBox(height: 6),

                  // Email display
                  Center(
                    child: Text(
                      FirebaseAuth.instance.currentUser?.email ?? '',
                      style: const TextStyle(color: _textColor, fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Status info card (role-specific)
                  if (isStudent)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: _sage.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _sage, width: 1.2),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.favorite, color: _terracotta, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '$_favoritesCount propiedades guardadas en favoritos',
                              style: const TextStyle(
                                color: _textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (isLandlord)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: _sage.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _sage, width: 1.2),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.home_work, color: _terracotta, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '$_myPropertiesCount propiedades publicadas',
                              style: const TextStyle(
                                color: _textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 18),

                  // Common fields
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre completo',
                      labelStyle: const TextStyle(color: _textColor),
                      prefixIcon: const Icon(Icons.person, color: _terracotta),
                      filled: true,
                      fillColor: Colors.white,
                      border: inputBorder,
                      enabledBorder: inputBorder,
                      focusedBorder: focusedBorder,
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Teléfono / WhatsApp',
                      labelStyle: const TextStyle(color: _textColor),
                      prefixIcon: const Icon(Icons.phone, color: _terracotta),
                      filled: true,
                      fillColor: Colors.white,
                      border: inputBorder,
                      enabledBorder: inputBorder,
                      focusedBorder: focusedBorder,
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: _bioController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Descripción / Presentación corta',
                      hintText: 'Cuéntanos un poco sobre ti...',
                      labelStyle: const TextStyle(color: _textColor),
                      prefixIcon: const Icon(Icons.notes, color: _terracotta),
                      filled: true,
                      fillColor: Colors.white,
                      border: inputBorder,
                      enabledBorder: inputBorder,
                      focusedBorder: focusedBorder,
                    ),
                  ),

                  // Student fields
                  if (isStudent) ...[
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: universities.containsKey(_selectedUniversity)
                          ? _selectedUniversity
                          : defaultUniversity,
                      decoration: InputDecoration(
                        labelText: '¿A qué universidad asistes?',
                        labelStyle: const TextStyle(color: _textColor),
                        prefixIcon: const Icon(Icons.school, color: _terracotta),
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
                    const SizedBox(height: 14),
                    TextField(
                      controller: _careerController,
                      decoration: InputDecoration(
                        labelText: 'Carrera / Semestre',
                        hintText: 'Ej. Ing. en Desarrollo de Software - 8°',
                        labelStyle: const TextStyle(color: _textColor),
                        prefixIcon: const Icon(Icons.book, color: _terracotta),
                        filled: true,
                        fillColor: Colors.white,
                        border: inputBorder,
                        enabledBorder: inputBorder,
                        focusedBorder: focusedBorder,
                      ),
                    ),
                  ],

                  // Landlord fields
                  if (isLandlord) ...[
                    const SizedBox(height: 14),
                    TextField(
                      controller: _scheduleController,
                      decoration: InputDecoration(
                        labelText: 'Horario de atención para visitas',
                        hintText: 'Ej. Lun - Sáb, 10:00 AM - 6:00 PM',
                        labelStyle: const TextStyle(color: _textColor),
                        prefixIcon: const Icon(Icons.schedule, color: _terracotta),
                        filled: true,
                        fillColor: Colors.white,
                        border: inputBorder,
                        enabledBorder: inputBorder,
                        focusedBorder: focusedBorder,
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // Action buttons
                  ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _terracotta,
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
                      foregroundColor: _terracotta,
                      side: const BorderSide(color: _terracotta, width: 1.5),
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
