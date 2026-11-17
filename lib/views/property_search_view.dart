import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';
import 'package:nidou/models/property.dart';
import 'package:nidou/utils/universities.dart';
import 'package:nidou/views/profile_view.dart';
import 'package:nidou/views/publish_property_view.dart';
import 'package:nidou/widgets/property_image.dart';
import 'property_detail_view.dart';

class PropertySearchView extends StatefulWidget {
  const PropertySearchView({Key? key}) : super(key: key);

  @override
  State<PropertySearchView> createState() => _PropertySearchViewState();
}

class _PropertySearchViewState extends State<PropertySearchView> {
  static const Color _terracota = Color(0xFFB85042);
  static const Color _arena = Color(0xFFE7E8D1);
  static const Color _texto = Color(0xFF3A2E2A);

  String _userRole = '';
  String _selectedUniversity = 'Todas las universidades';
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        final data = doc.data() ?? {};
        _userRole = (data['role'] ?? '').toString().toUpperCase();
        final userUniv = data['university'] as String?;
        if (userUniv != null && universities.containsKey(userUniv)) {
          _selectedUniversity = userUniv;
        }
      } catch (_) {}
    }
    if (mounted) {
      setState(() {
        _isLoadingUser = false;
      });
    }
  }

  Stream<List<Property>> _propertyStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final base = FirebaseFirestore.instance.collection('properties').snapshots();
    if (_userRole == 'ARRENDADOR' && uid != null) {
      return base.map((snapshot) => snapshot.docs
          .map((doc) => Property.fromFirestore(doc))
          .where((p) => p.ownerId == uid)
          .toList());
    }
    // ESTUDIANTE or unknown role: all properties
    return base.map((snapshot) => snapshot.docs.map((doc) => Property.fromFirestore(doc)).toList());
  }

  List<Property> _sortAndFilterProperties(List<Property> properties) {
    if (_userRole != 'ESTUDIANTE' || _selectedUniversity == 'Todas las universidades') {
      return properties;
    }

    final targetCoords = universities[_selectedUniversity];
    final selectedCity = _selectedUniversity.toLowerCase();

    // Crear una lista mutable
    final list = List<Property>.from(properties);

    list.sort((a, b) {
      // 1. Coincidencia exacta de universidad
      final aMatchesUniv = (a.university ?? '').trim() == _selectedUniversity.trim();
      final bMatchesUniv = (b.university ?? '').trim() == _selectedUniversity.trim();
      if (aMatchesUniv && !bMatchesUniv) return -1;
      if (!aMatchesUniv && bMatchesUniv) return 1;

      // 2. Coincidencia de nombre de ciudad / región en location
      final aLocation = a.location.toLowerCase();
      final bLocation = b.location.toLowerCase();
      bool aMatchesCity = false;
      bool bMatchesCity = false;
      if (selectedCity.contains('dolores')) {
        aMatchesCity = aLocation.contains('dolores');
        bMatchesCity = bLocation.contains('dolores');
      } else if (selectedCity.contains('salvatierra')) {
        aMatchesCity = aLocation.contains('salvatierra');
        bMatchesCity = bLocation.contains('salvatierra');
      } else if (selectedCity.contains('bicentenario') || selectedCity.contains('silao')) {
        aMatchesCity = aLocation.contains('silao') || aLocation.contains('bicentenario');
        bMatchesCity = bLocation.contains('silao') || bLocation.contains('bicentenario');
      }

      if (aMatchesCity && !bMatchesCity) return -1;
      if (!aMatchesCity && bMatchesCity) return 1;

      // 3. Minutos a pie (si tiene coordenadas reales calcular a la univ, sino usar distanceMinutes)
      int aMinutes = a.distanceMinutes;
      int bMinutes = b.distanceMinutes;
      if (targetCoords != null && a.latitude != null && a.longitude != null) {
        aMinutes = calculateWalkingMinutes(LatLng(a.latitude!, a.longitude!), targetCoords);
      }
      if (targetCoords != null && b.latitude != null && b.longitude != null) {
        bMinutes = calculateWalkingMinutes(LatLng(b.latitude!, b.longitude!), targetCoords);
      }

      return aMinutes.compareTo(bMinutes);
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = _userRole == 'ARRENDADOR';
    final isStudent = _userRole == 'ESTUDIANTE';

    return Scaffold(
      backgroundColor: _arena,
      appBar: AppBar(
        title: Text(isOwner ? 'Mis propiedades' : 'Buscar alojamiento'),
        backgroundColor: _terracota,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Mi perfil',
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileView()));
              _loadUserData();
            },
          ),
        ],
      ),
      body: _isLoadingUser
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (isStudent)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.school, size: 20, color: _terracota),
                        const SizedBox(width: 8),
                        const Text(
                          'Mi universidad:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _texto),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedUniversity,
                              isDense: true,
                              isExpanded: true,
                              style: const TextStyle(fontSize: 12, color: _texto, fontWeight: FontWeight.w600),
                              icon: const Icon(Icons.arrow_drop_down, color: _terracota),
                              items: [
                                const DropdownMenuItem(
                                  value: 'Todas las universidades',
                                  child: Text('Todas las universidades', overflow: TextOverflow.ellipsis),
                                ),
                                ...universities.keys.map((univ) {
                                  return DropdownMenuItem(
                                    value: univ,
                                    child: Text(univ, overflow: TextOverflow.ellipsis),
                                  );
                                }),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedUniversity = val);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: StreamBuilder<List<Property>>(
                    stream: _propertyStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final rawProperties = snapshot.data ?? [];
                      final properties = _sortAndFilterProperties(rawProperties);

                      if (properties.isEmpty) {
                        return const Center(child: Text('No hay propiedades disponibles'));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: properties.length,
                        itemBuilder: (context, index) {
                          final property = properties[index];
                          final priceText = '\$${property.price.toStringAsFixed(0)}/mes';

                          int displayMinutes = property.distanceMinutes;
                          if (isStudent &&
                              _selectedUniversity != 'Todas las universidades' &&
                              property.latitude != null &&
                              property.longitude != null) {
                            final targetCoords = universities[_selectedUniversity];
                            if (targetCoords != null) {
                              displayMinutes = calculateWalkingMinutes(
                                LatLng(property.latitude!, property.longitude!),
                                targetCoords,
                              );
                            }
                          }

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            clipBehavior: Clip.antiAlias,
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: InkWell(
                              onTap: () async {
                                final changed = await Navigator.of(context).push<bool>(
                                  MaterialPageRoute(builder: (_) => PropertyDetailView(property: property)),
                                );
                                if (changed == true && mounted) {
                                  setState(() {});
                                }
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  PropertyImage(urls: property.photos),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                property.title,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              priceText,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFB85042),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                property.location,
                                                style: const TextStyle(color: Colors.black87),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.directions_walk, size: 16, color: Color(0xFFB85042)),
                                            const SizedBox(width: 4),
                                            Text(
                                              '$displayMinutes min a pie',
                                              style: const TextStyle(color: Colors.black54, fontSize: 13),
                                            ),
                                            if (property.university != null && property.university!.isNotEmpty) ...[
                                              const SizedBox(width: 8),
                                              const Text('•', style: TextStyle(color: Colors.black38)),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  property.university!,
                                                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: isOwner
          ? FloatingActionButton(
              onPressed: () async {
                final created = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const PublishPropertyView()),
                );
                if (created == true && mounted) {
                  setState(() {});
                }
              },
              tooltip: 'Publicar propiedad',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
