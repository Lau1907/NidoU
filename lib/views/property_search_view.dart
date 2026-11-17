import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/property_search_viewmodel.dart';
import 'property_detail_view.dart';
import 'publish_property_view.dart';

class PropertySearchView extends StatelessWidget {
  const PropertySearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PropertySearchViewModel()..loadProperties(),
      child: const _PropertySearchBody(),
    );
  }
}

class _PropertySearchBody extends StatefulWidget {
  const _PropertySearchBody();

  @override
  State<_PropertySearchBody> createState() => _PropertySearchViewState();
}

class _PropertySearchViewState extends State<_PropertySearchBody> {
  static const Color terracota = Color(0xFFB85042);
  static const Color arena = Color(0xFFE7E8D1);
  static const Color salvia = Color(0xFFA7BEAE);
  static const Color texto = Color(0xFF3A2E2A);

  final TextEditingController _searchCtrl = TextEditingController();
  bool _isLandlord = false;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final role = (doc.data()?['role'] ?? doc.data()?['rol'] ?? '').toString().toLowerCase();
      if (mounted) {
        setState(() => _isLandlord = role == 'arrendador' || role == 'landlord');
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showFilterSheet(PropertySearchViewModel vm) {
    double tempPrice = vm.maxPrice ?? 10000;
    int tempDist = vm.maxDistance ?? 60;

    showModalBottomSheet(
      context: context,
      backgroundColor: arena,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filtros avanzados',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: texto)),
              const SizedBox(height: 16),
              Text('Precio máximo: \$${tempPrice.toStringAsFixed(0)} MXN/mes',
                  style: const TextStyle(color: texto)),
              Slider(
                value: tempPrice,
                min: 1000,
                max: 15000,
                divisions: 28,
                activeColor: terracota,
                onChanged: (v) => setModalState(() => tempPrice = v),
              ),
              Text('Distancia máxima: $tempDist min a pie', style: const TextStyle(color: texto)),
              Slider(
                value: tempDist.toDouble(),
                min: 5,
                max: 60,
                divisions: 11,
                activeColor: terracota,
                onChanged: (v) => setModalState(() => tempDist = v.round()),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        vm.clearFilters();
                        _searchCtrl.clear();
                        Navigator.pop(ctx);
                      },
                      child: const Text('Limpiar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: terracota,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        vm.setMaxPrice(tempPrice);
                        vm.setMaxDistance(tempDist);
                        Navigator.pop(ctx);
                      },
                      child: const Text('Aplicar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PropertySearchViewModel>();

    return Scaffold(
      backgroundColor: arena,
      appBar: AppBar(
        title: const Text('Buscar alojamiento'),
        backgroundColor: terracota,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Filtros',
            icon: const Icon(Icons.tune),
            onPressed: () => _showFilterSheet(vm),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      floatingActionButton: _isLandlord
          ? FloatingActionButton.extended(
              backgroundColor: terracota,
              foregroundColor: Colors.white,
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PublishPropertyView()),
                );
                if (mounted) vm.loadProperties();
              },
              icon: const Icon(Icons.add),
              label: const Text('Publicar propiedad'),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: TextField(
              controller: _searchCtrl,
              onChanged: vm.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Buscar por título o colonia...',
                prefixIcon: const Icon(Icons.search, color: terracota),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          vm.setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                for (final entry in {
                  'todos': 'Todos',
                  'habitacion': 'Habitación',
                  'departamento': 'Departamento',
                  'estudio': 'Estudio',
                }.entries)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(entry.value),
                      selected: vm.selectedType == entry.key,
                      selectedColor: salvia,
                      onSelected: (_) => vm.setSelectedType(entry.key),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: vm.loadProperties,
              child: _buildList(vm),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(PropertySearchViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator(color: terracota));
    }
    if (vm.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(vm.errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: texto)),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: terracota, foregroundColor: Colors.white),
                onPressed: vm.loadProperties,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }
    if (vm.filteredProperties.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          const Icon(Icons.search_off, size: 56, color: texto),
          const SizedBox(height: 12),
          const Center(
            child: Text('No hay propiedades con estos filtros', style: TextStyle(color: texto)),
          ),
          const SizedBox(height: 12),
          Center(
            child: OutlinedButton(
              onPressed: () {
                _searchCtrl.clear();
                vm.clearFilters();
              },
              child: const Text('Limpiar filtros'),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
      itemCount: vm.filteredProperties.length,
      itemBuilder: (_, i) {
        final property = vm.filteredProperties[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PropertyDetailView(property: property)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: property.photos.isNotEmpty
                      ? Image.network(
                          property.photos.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: salvia.withValues(alpha: 0.3),
                            child: const Icon(Icons.home, size: 48, color: texto),
                          ),
                        )
                      : Container(
                          color: salvia.withValues(alpha: 0.3),
                          child: const Icon(Icons.home, size: 48, color: texto),
                        ),
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
                                  fontSize: 17, fontWeight: FontWeight.bold, color: texto),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '\$${property.price.toStringAsFixed(0)}/mes',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold, color: terracota),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(property.location,
                          style: const TextStyle(color: texto, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.directions_walk, size: 16, color: terracota),
                          const SizedBox(width: 4),
                          Text('${property.distanceMinutes} min a pie',
                              style: const TextStyle(fontSize: 13, color: texto)),
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
  }
}