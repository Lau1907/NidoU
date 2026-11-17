import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/property.dart';

class PropertyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Property> createProperty(Property property) async {
    final docRef = await _firestore
        .collection('properties')
        .add(property.toMap());
    final doc = await docRef.get();
    return Property.fromFirestore(doc);
  }

  Future<void> updateProperty(Property property) async {
    final data = property.toMap();
    // No sobrescribir createdAt si ya existe
    data.remove('createdAt');
    await _firestore
        .collection('properties')
        .doc(property.id)
        .update(data);
  }

  Future<void> deleteProperty(String propertyId) async {
    await _firestore.collection('properties').doc(propertyId).delete();
  }

  Future<List<Property>> getProperties() async {
    try {
      final snapshot = await _firestore.collection('properties').get();
      final List<Property> list = [];
      for (final doc in snapshot.docs) {
        try {
          list.add(Property.fromFirestore(doc));
        } catch (e) {
          debugPrint('Error parseando propiedad ${doc.id}: $e');
        }
      }
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (e) {
      debugPrint('Error en getProperties: $e');
      rethrow;
    }
  }

  Future<dynamic> getOwnerById(String ownerId) async {
    if (ownerId.isEmpty) return null;
    final doc = await _firestore.collection('users').doc(ownerId).get();
    if (!doc.exists) return null;
    return doc.data();
  }
}
