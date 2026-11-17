import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:nidou/models/property.dart';
import 'package:nidou/repositories/property_repository.dart';
import 'package:nidou/utils/universities.dart';
import 'package:nidou/widgets/property_image.dart';

class PublishPropertyView extends StatefulWidget {
  final Property? propertyToEdit;

  const PublishPropertyView({super.key, this.propertyToEdit});

  @override
  State<PublishPropertyView> createState() => _PublishPropertyViewState();
}

class _PublishPropertyViewState extends State<PublishPropertyView> {
  // Paleta de colores de NidoU
  static const Color _terracota = Color(0xFFB85042);
  static const Color _arena = Color(0xFFE7E8D1);
  static const Color _salvia = Color(0xFFA7BEAE);
  static const Color _texto = Color(0xFF3A2E2A);

  final _formKey = GlobalKey<FormState>();

  // 1. Fotos
  final List<String> _photos = [];
  final ImagePicker _picker = ImagePicker();

  // 2. Datos principales
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String _selectedType = 'habitacion';
  final TextEditingController _descriptionController = TextEditingController();

  // 3. Servicios incluidos
  final List<String> _availableServices = const [
    'Agua',
    'Luz',
    'Internet',
    'Amueblado',
    'Lavandería',
    'Estacionamiento',
  ];
  final Set<String> _selectedServices = {};

  // 4. Ubicación y cercanía
  String _selectedUniversity = defaultUniversity;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  final MapController _mapController = MapController();
  LatLng? _selectedPoint;
  bool _isLoadingAddress = false;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final edit = widget.propertyToEdit;
    if (edit != null) {
      _titleController.text = edit.title;
      _priceController.text = edit.price.toStringAsFixed(0);
      _selectedType = edit.type.isNotEmpty ? edit.type : 'habitacion';
      _descriptionController.text = edit.description;
      _selectedServices.addAll(edit.services);
      _photos.addAll(edit.photos);
      if (edit.university != null && universities.containsKey(edit.university)) {
        _selectedUniversity = edit.university!;
      }
      _locationController.text = edit.location;
      _minutesController.text = edit.distanceMinutes.toString();

      if (edit.latitude != null && edit.longitude != null) {
        _selectedPoint = LatLng(edit.latitude!, edit.longitude!);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    if (_photos.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solo puedes agregar un máximo de 3 fotos.')),
      );
      return;
    }

    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 45,
      maxWidth: 800,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    final dataUri = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    setState(() {
      _photos.add(dataUri);
    });
  }

  void _removePhoto(int index) {
    if (index >= 0 && index < _photos.length) {
      setState(() {
        _photos.removeAt(index);
      });
    }
  }

  void _onUniversityChanged(String? newUniv) {
    if (newUniv == null || newUniv == _selectedUniversity) return;
    setState(() {
      _selectedUniversity = newUniv;
    });

    final univCoords = universities[newUniv];
    if (univCoords != null) {
      _mapController.move(univCoords, 14);
      if (_selectedPoint != null) {
        final minutes = calculateWalkingMinutes(_selectedPoint!, univCoords);
        _minutesController.text = minutes.toString();
      }
    }
  }

  Future<void> _onMapTapped(LatLng point) async {
    setState(() {
      _selectedPoint = point;
      _isLoadingAddress = true;
    });

    // 1. Calcular minutos automáticamente hacia la universidad seleccionada
    final univCoords = universities[_selectedUniversity] ?? universities[defaultUniversity]!;
    final minutes = calculateWalkingMinutes(point, univCoords);
    _minutesController.text = minutes.toString();

    // 2. Reverse geocoding con OpenStreetMap Nominatim
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${point.latitude}&lon=${point.longitude}',
      );
      final response = await http.get(url, headers: {
        'User-Agent': 'NidoUApp/1.0',
      }).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>? ?? {};

        final road = address['road'] ?? address['pedestrian'] ?? address['street'];
        final suburb = address['suburb'] ?? address['neighbourhood'] ?? address['quarter'];
        final city = address['city'] ?? address['town'] ?? address['village'] ?? address['municipality'];

        String resolvedText = '';
        if (road != null || suburb != null || city != null) {
          final parts = [road, suburb, city].where((p) => p != null && p.toString().isNotEmpty).toList();
          resolvedText = parts.join(', ');
        } else {
          resolvedText = data['display_name']?.toString() ?? '';
        }

        if (resolvedText.isEmpty) {
          resolvedText = 'Ubicación marcada (${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)})';
        }

        if (mounted) {
          setState(() {
            _locationController.text = resolvedText;
            _isLoadingAddress = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _locationController.text =
                'Ubicación marcada (${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)})';
            _isLoadingAddress = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _locationController.text =
              'Ubicación marcada (${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)})';
          _isLoadingAddress = false;
        });
      }
    }
  }

  Future<void> _submitProperty() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes agregar al menos una foto de la propiedad.')),
      );
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    final ownerId = currentUser?.uid ?? '';
    if (ownerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró una sesión activa de arrendador.')),
      );
      return;
    }

    final price = double.tryParse(_priceController.text.trim().replaceAll(',', '.')) ?? 0.0;
    final distanceMinutes = int.tryParse(_minutesController.text.trim()) ?? 0;

    setState(() => _isSubmitting = true);

    final isEditing = widget.propertyToEdit != null;

    try {
      final property = Property(
        id: isEditing ? widget.propertyToEdit!.id : '',
        title: _titleController.text.trim(),
        price: price,
        distanceMinutes: distanceMinutes,
        type: _selectedType,
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        services: _selectedServices.toList(),
        photos: List<String>.from(_photos),
        ownerId: ownerId,
        createdAt: isEditing ? widget.propertyToEdit!.createdAt : DateTime.now(),
        university: _selectedUniversity,
        latitude: _selectedPoint?.latitude,
        longitude: _selectedPoint?.longitude,
      );

      if (isEditing) {
        await PropertyRepository().updateProperty(property);
      } else {
        await PropertyRepository().createProperty(property);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Propiedad actualizada con éxito' : 'Propiedad publicada con éxito'),
          backgroundColor: _terracota,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar propiedad: $e')),
      );
    }
  }

  InputDecoration _buildInputDecoration(String label, {Widget? suffixIcon}) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Colors.black26),
    );
    const focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: _terracota, width: 2),
    );
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _texto),
      filled: true,
      fillColor: Colors.white,
      border: border,
      enabledBorder: border,
      focusedBorder: focusedBorder,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.propertyToEdit != null;
    final selectedPoint = _selectedPoint;
    final initialUnivCoords = universities[_selectedUniversity] ?? universities[defaultUniversity]!;

    return Scaffold(
      backgroundColor: _arena,
      appBar: AppBar(
        title: Text(isEditing ? 'Editar propiedad' : 'Publicar propiedad'),
        backgroundColor: _terracota,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ==========================================
            // 1. Fotos de la propiedad (máx. 3)
            // ==========================================
            const Text(
              'Fotos de la propiedad (máx. 3)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _texto),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _photos.length >= 3 || _isSubmitting ? null : _pickPhoto,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Seleccionar foto de la galería'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _terracota,
                side: const BorderSide(color: _terracota, width: 1.5),
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            if (_photos.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 110,
                            height: 110,
                            child: PropertyImage.single(imageUrl: _photos[index]),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: _isSubmitting ? null : () => _removePhoto(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 20),

            // ==========================================
            // 2. Datos principales de la propiedad
            // ==========================================
            const Text(
              'Datos principales',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _texto),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: _buildInputDecoration('Título del anuncio'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'El título es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: _buildInputDecoration('Renta mensual (\$ MXN)'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Ingresa la renta';
                      }
                      final n = double.tryParse(v.trim().replaceAll(',', '.'));
                      if (n == null || n <= 0) {
                        return 'Renta inválida';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    decoration: _buildInputDecoration('Tipo'),
                    dropdownColor: Colors.white,
                    items: const [
                      DropdownMenuItem(
                        value: 'habitacion',
                        child: Text('Habitación'),
                      ),
                      DropdownMenuItem(
                        value: 'departamento',
                        child: Text('Departamento'),
                      ),
                      DropdownMenuItem(
                        value: 'estudio',
                        child: Text('Estudio'),
                      ),
                    ],
                    onChanged: _isSubmitting
                        ? null
                        : (val) {
                            if (val != null) {
                              setState(() => _selectedType = val);
                            }
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: _buildInputDecoration('Descripción'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'La descripción es obligatoria';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // ==========================================
            // 3. Servicios incluidos
            // ==========================================
            const Text(
              'Servicios incluidos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _texto),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableServices.map((service) {
                final isSelected = _selectedServices.contains(service);
                return FilterChip(
                  label: Text(
                    service,
                    style: TextStyle(
                      color: isSelected ? Colors.white : _texto,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: _salvia,
                  checkmarkColor: Colors.white,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onSelected: _isSubmitting
                      ? null
                      : (bool selected) {
                          setState(() {
                            if (selected) {
                              _selectedServices.add(service);
                            } else {
                              _selectedServices.remove(service);
                            }
                          });
                        },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ==========================================
            // 4. Ubicación y cercanía (en Card blanca)
            // ==========================================
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ubicación y cercanía',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _texto),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedUniversity,
                      decoration: _buildInputDecoration('Universidad cercana'),
                      dropdownColor: Colors.white,
                      isExpanded: true,
                      items: universities.keys.map((univ) {
                        return DropdownMenuItem<String>(
                          value: univ,
                          child: Text(
                            univ,
                            style: const TextStyle(fontSize: 13, color: _texto),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: _isSubmitting ? null : _onUniversityChanged,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _locationController,
                      decoration: _buildInputDecoration(
                        'Dirección o colonia',
                        suffixIcon: _isLoadingAddress
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: _terracota),
                                ),
                              )
                            : null,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'La dirección o colonia es obligatoria';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 180,
                        width: double.infinity,
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: selectedPoint ?? initialUnivCoords,
                            initialZoom: 13,
                            onTap: _isSubmitting ? null : (tapPos, point) => _onMapTapped(point),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.nidou',
                            ),
                            MarkerLayer(
                              markers: [
                                // Marcador de la universidad seleccionada
                                Marker(
                                  point: universities[_selectedUniversity] ?? universities[defaultUniversity]!,
                                  width: 36,
                                  height: 36,
                                  child: const Icon(
                                    Icons.school,
                                    color: _terracota,
                                    size: 32,
                                  ),
                                ),
                                // Marcador del punto seleccionado para la propiedad
                                if (selectedPoint != null)
                                  Marker(
                                    point: selectedPoint,
                                    width: 40,
                                    height: 40,
                                    child: const Icon(
                                      Icons.location_pin,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _minutesController,
                      keyboardType: TextInputType.number,
                      decoration: _buildInputDecoration('Minutos a pie hacia la universidad'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Ingresa los minutos a pie';
                        }
                        final mins = int.tryParse(v.trim());
                        if (mins == null || mins < 0) {
                          return 'Ingresa un número entero válido';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ==========================================
            // 5. Botón "Guardar cambios" o "Publicar propiedad"
            // ==========================================
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitProperty,
              style: ElevatedButton.styleFrom(
                backgroundColor: _terracota,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      isEditing ? 'Guardar cambios' : 'Publicar propiedad',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
