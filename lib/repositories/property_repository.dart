import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/property.dart';

class PropertyRepository {
  final FirebaseFirestore? _firestore;

  PropertyRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore;

  FirebaseFirestore get _effectiveFirestore =>
      _firestore ?? FirebaseFirestore.instance;

  /// Guarda el documento de la propiedad en la colección "properties" de Firestore.
  /// La propiedad ya incluye su lista de URLs en el campo photos.
  Future<Property> createProperty(Property property) async {
    final docRef = _effectiveFirestore.collection('properties').doc();
    final propertyToSave = property.copyWith(id: docRef.id);

    await docRef.set(propertyToSave.toMap());

    return propertyToSave;
  }
}
