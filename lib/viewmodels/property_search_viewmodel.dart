import 'package:flutter/material.dart';
import '../models/property.dart';
import '../repositories/property_repository.dart';

class PropertySearchViewModel extends ChangeNotifier {
  final PropertyRepository _repository;

  PropertySearchViewModel({PropertyRepository? repository})
      : _repository = repository ?? PropertyRepository();

  List<Property> _properties = [];
  List<Property> _filtered = [];
  bool isLoading = false;
  String? errorMessage;

  String searchQuery = '';
  double? maxPrice;
  int? maxDistance;
  String selectedType = 'todos';

  List<Property> get properties => _properties;
  List<Property> get filteredProperties => _filtered;

  Future<void> loadProperties() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _properties = await _repository.getProperties();
      _applyFilters();
    } catch (e) {
      errorMessage = 'No se pudieron cargar las propiedades: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setMaxPrice(double? price) {
    maxPrice = price;
    _applyFilters();
    notifyListeners();
  }

  void setMaxDistance(int? minutes) {
    maxDistance = minutes;
    _applyFilters();
    notifyListeners();
  }

  void setSelectedType(String type) {
    selectedType = type;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    searchQuery = '';
    maxPrice = null;
    maxDistance = null;
    selectedType = 'todos';
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    final q = searchQuery.trim().toLowerCase();
    _filtered = _properties.where((p) {
      final matchesQuery = q.isEmpty ||
          p.title.toLowerCase().contains(q) ||
          p.location.toLowerCase().contains(q);
      final matchesPrice = maxPrice == null || p.price <= maxPrice!;
      final matchesDist =
          maxDistance == null || p.distanceMinutes <= maxDistance!;
      final matchesType = selectedType == 'todos' ||
          p.type.toLowerCase() == selectedType.toLowerCase();
      return matchesQuery && matchesPrice && matchesDist && matchesType;
    }).toList();
  }
}