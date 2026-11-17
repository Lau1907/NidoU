import 'package:flutter/foundation.dart';
import '../models/property.dart';
import '../repositories/property_repository.dart';

class PublishPropertyViewModel extends ChangeNotifier {
  final PropertyRepository _propertyRepository;

  static const int maxPhotos = 3;

  bool _isLoading = false;
  String? _errorMessage;
  final List<String> _photoUrls = [];

  PublishPropertyViewModel({PropertyRepository? propertyRepository})
      : _propertyRepository = propertyRepository ?? PropertyRepository();

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<String> get photoUrls => List.unmodifiable(_photoUrls);

  // State management helpers
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void clearPhotos() {
    _photoUrls.clear();
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _photoUrls.clear();
    notifyListeners();
  }

  /// Adds a photo (URL or Base64) to the list (max 3).
  bool addPhotoUrl(String photo) {
    if (_photoUrls.length >= maxPhotos) {
      _errorMessage = 'Solo puedes agregar un máximo de $maxPhotos fotos.';
      notifyListeners();
      return false;
    }
    final clean = photo.trim();
    if (clean.isEmpty) {
      _errorMessage = 'Por favor, agrega una foto.';
      notifyListeners();
      return false;
    }
    _photoUrls.add(clean);
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  void removePhotoUrl(int index) {
    if (index >= 0 && index < _photoUrls.length) {
      _photoUrls.removeAt(index);
      _errorMessage = null;
      notifyListeners();
    }
  }

  void removePhoto(dynamic photoOrIndex) {
    if (photoOrIndex is int) {
      removePhotoUrl(photoOrIndex);
    } else if (photoOrIndex is String) {
      final removed = _photoUrls.remove(photoOrIndex);
      if (removed) {
        _errorMessage = null;
        notifyListeners();
      }
    }
  }

  /// Publishes a property to Firestore.
  Future<bool> publish({
    String? title,
    dynamic price,
    int distanceMinutes = 0,
    String type = Property.typeHabitacion,
    String? location,
    String description = '',
    List<String> services = const [],
    required String ownerId,
    Property? property,
  }) async {
    final effectiveTitle = property?.title ?? title ?? '';
    final effectiveLocation = property?.location ?? location ?? '';
    final effectiveDescription = property?.description ?? description;
    final effectiveType = property?.type ?? type;
    final effectiveDistance = property?.distanceMinutes ?? distanceMinutes;
    final effectiveServices = property?.services ?? services;
    final effectiveOwnerId = property?.ownerId ?? ownerId;

    double? parsedPrice;
    if (property != null) {
      parsedPrice = property.price;
    } else if (price is num) {
      parsedPrice = price.toDouble();
    } else if (price is String) {
      parsedPrice = double.tryParse(price.trim().replaceAll(',', '.'));
    }

    if (effectiveTitle.trim().isEmpty) {
      _errorMessage = 'Por favor, ingresa el título de la publicación.';
      notifyListeners();
      return false;
    }
    if (parsedPrice == null || parsedPrice <= 0) {
      _errorMessage = 'Por favor, ingresa un precio mensual válido mayor a 0.';
      notifyListeners();
      return false;
    }
    if (effectiveLocation.trim().isEmpty) {
      _errorMessage = 'Por favor, ingresa la ubicación de la propiedad.';
      notifyListeners();
      return false;
    }

    final effectivePhotos = property?.photos ?? _photoUrls;
    if (effectivePhotos.isEmpty) {
      _errorMessage = 'Debes agregar al menos una foto de la propiedad.';
      notifyListeners();
      return false;
    }
    // No prefix validation – accept Base64 or URLs.

    if (effectiveOwnerId.trim().isEmpty) {
      _errorMessage = 'No fue posible identificar la cuenta del arrendador.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final propertyToCreate = Property(
        id: '',
        title: effectiveTitle.trim(),
        price: parsedPrice,
        distanceMinutes: effectiveDistance,
        type: effectiveType,
        location: effectiveLocation.trim(),
        description: effectiveDescription.trim(),
        services: List<String>.from(effectiveServices),
        photos: List<String>.from(effectivePhotos),
        ownerId: effectiveOwnerId.trim(),
        createdAt: DateTime.now(),
      );
      await _propertyRepository.createProperty(propertyToCreate);
      _photoUrls.clear();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Ocurrió un error al publicar la propiedad: $e';
      notifyListeners();
      return false;
    }
  }
}
