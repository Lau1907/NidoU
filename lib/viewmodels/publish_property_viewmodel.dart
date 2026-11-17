import 'package:flutter/foundation.dart';
import '../models/property.dart';
import '../repositories/property_repository.dart';

class PublishPropertyViewModel extends ChangeNotifier {
  final PropertyRepository _propertyRepository;

  static const int maxPhotos = 3;

  bool _isLoading = false;
  String? _errorMessage;
  final List<String> _photoUrls = [];

  PublishPropertyViewModel({
    PropertyRepository? propertyRepository,
  }) : _propertyRepository = propertyRepository ?? PropertyRepository();

  // Getters de estado
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<String> get photoUrls => List.unmodifiable(_photoUrls);
  List<String> get selectedPhotos => photoUrls;

  /// Limpia el mensaje de error actual
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Limpia la lista de fotos agregadas
  void clearPhotos() {
    _photoUrls.clear();
    notifyListeners();
  }

  /// Restablece todo el estado del ViewModel
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _photoUrls.clear();
    notifyListeners();
  }

  /// Agrega una URL de imagen a la lista (máximo 3).
  /// Valida que la URL comience con https://.
  bool addPhotoUrl(String url) {
    if (_photoUrls.length >= maxPhotos) {
      _errorMessage = 'Solo puedes agregar un máximo de $maxPhotos fotos.';
      notifyListeners();
      return false;
    }

    final cleanUrl = url.trim();
    if (cleanUrl.isEmpty) {
      _errorMessage = 'Por favor, ingresa el enlace de la foto.';
      notifyListeners();
      return false;
    }

    if (!cleanUrl.startsWith('https://')) {
      _errorMessage =
          'El enlace debe comenzar con https:// (por seguridad no se permite http).';
      notifyListeners();
      return false;
    }

    if (_photoUrls.contains(cleanUrl)) {
      _errorMessage = 'Esta foto ya ha sido agregada.';
      notifyListeners();
      return false;
    }

    _photoUrls.add(cleanUrl);
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  /// Elimina una foto por su índice
  void removePhotoUrl(int index) {
    if (index >= 0 && index < _photoUrls.length) {
      _photoUrls.removeAt(index);
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Método compatible para eliminar por índice o URL
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

  /// Valida los campos requeridos y publica la propiedad en Firestore.
  /// Valida: título, precio (>0), ubicación y al menos una foto (URL con https://).
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

    // Resolución de precio numérico
    double? parsedPrice;
    if (property != null) {
      parsedPrice = property.price;
    } else if (price is num) {
      parsedPrice = price.toDouble();
    } else if (price is String) {
      parsedPrice = double.tryParse(price.trim().replaceAll(',', '.'));
    }

    // Validaciones en español
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
      _errorMessage =
          'Debes agregar al menos una foto (enlace con https://) de la propiedad.';
      notifyListeners();
      return false;
    }

    if (effectivePhotos.any((url) => !url.trim().startsWith('https://'))) {
      _errorMessage =
          'Todos los enlaces de fotos deben comenzar con https://.';
      notifyListeners();
      return false;
    }

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
        services: effectiveServices,
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
