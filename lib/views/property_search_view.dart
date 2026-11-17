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
  Set<String> _favoriteIds = {};
  bool _showFavoritesOnly = false;

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
        // Load favorites
        final rawFavs = data['favorites'];
        if (rawFavs is List) {
          _favoriteIds = rawFavs.map((e) => e.toString()).toSet();
        }
      } catch (_) {}
    }
    if (mounted) {
      setState(() {
        _isLoadingUser = false;
      });
    }
  }

  Future<void> _toggleFavorite(String propertyId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final isFav = _favoriteIds.contains(propertyId);
    final update = isFav
        ? FieldValue.arrayRemove([propertyId])
        : FieldValue.arrayUnion([propertyId]);
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({'favorites': update});
      if (mounted) {
        setState(() {
          if (isFav) {
            _favoriteIds.remove(propertyId);
          } else {
            _favoriteIds.add(propertyId);
          }
        });
      }
    } catch (_) {}
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
    return base.map((snapshot) => snapshot.docs.map((doc) => Property.fromFirestore(doc)).toList());
  }

  List<Property> _sortAndFilterProperties(List<Property> properties) {
    var list = List<Property>.from(properties);

    // Filter favorites
    if (_showFavoritesOnly) {
      list = list.where((p) => _favoriteIds.contains(p.id)).toList();
    }

    if (_userRole != 'ESTUDIANTE' || _selectedUniversity == 'Todas las universidades') {
      return list;
    }

    final targetCoords = universities[_selectedUniversity];
    final selectedCity = _selectedUniversity.toLowerCase();

    list.sort((a, b) {
      final aMatchesUniv = (a.university ?? '').trim() == _selectedUniversity.trim();
      final bMatchesUniv = (b.university ?? '').trim() == _selectedUniversity.trim();
      if (aMatchesUniv && !bMatchesUniv) return -1;
      if (!aMatchesUniv && bMatchesUniv) return 1;

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

  String _typeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'habitacion':
      case 'habitación':
        return 'Habitación';
      case 'departamento':
        return 'Departamento';
      case 'estudio':
        return 'Estudio';
      default:
        return type;
    }
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                        const SizedBox(height: 6),
                        // Filter chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              FilterChip(
                                label: const Text('❤️ Favoritos'),
                                selected: _showFavoritesOnly,
                                selectedColor: _terracota.withValues(alpha: 0.15),
                                checkmarkColor: _terracota,
                                labelStyle: TextStyle(
                                  color: _showFavoritesOnly ? _terracota : _texto,
                                  fontWeight: _showFavoritesOnly ? FontWeight.bold : FontWeight.normal,
                                ),
                                onSelected: (val) => setState(() => _showFavoritesOnly = val),
                              ),
                            ],
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
                        return Center(
                          child: Text(
                            _showFavoritesOnly ? 'No tienes propiedades guardadas' : 'No hay propiedades disponibles',
                            style: const TextStyle(color: _texto),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              '${properties.length} alojamiento${properties.length == 1 ? '' : 's'} encontrado${properties.length == 1 ? '' : 's'}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _texto,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 16),
                              itemCount: properties.length,
                              itemBuilder: (context, index) {
                                final property = properties[index];
                                final priceText = '\$${property.price.toStringAsFixed(0)}/mes';
                                final isFav = _favoriteIds.contains(property.id);

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
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                                        // Photo with type badge + heart button
                                        Stack(
                                          children: [
                                            PropertyImage(urls: property.photos),
                                            // Type badge pill (top-left)
                                            Positioned(
                                              top: 10,
                                              left: 10,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: _terracota,
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  _typeLabel(property.type),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Favorite button (top-right, only for students)
                                            if (isStudent)
                                              Positioned(
                                                top: 4,
                                                right: 4,
                                                child: Material(
                                                  color: Colors.white.withValues(alpha: 0.85),
                                                  borderRadius: BorderRadius.circular(20),
                                                  child: InkWell(
                                                    borderRadius: BorderRadius.circular(20),
                                                    onTap: () => _toggleFavorite(property.id),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(6),
                                                      child: Icon(
                                                        isFav ? Icons.favorite : Icons.favorite_border,
                                                        color: _terracota,
                                                        size: 22,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
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
                                                        color: _texto,
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
                                                      color: _terracota,
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
                                                      style: const TextStyle(color: Colors.black87, fontSize: 13),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(Icons.directions_walk, size: 16, color: _terracota),
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
                            ),
                          ),
                        ],
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
              backgroundColor: _terracota,
              tooltip: 'Publicar propiedad',
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
