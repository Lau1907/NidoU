import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for Clipboard
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/property.dart';
import '../repositories/property_repository.dart';
import 'package:nidou/views/publish_property_view.dart';
import 'package:nidou/widgets/property_image.dart';

class PropertyDetailView extends StatefulWidget {
  final Property property;

  const PropertyDetailView({super.key, required this.property});

  @override
  State<PropertyDetailView> createState() => _PropertyDetailViewState();
}

class _PropertyDetailViewState extends State<PropertyDetailView> {
  static const Color terracota = Color(0xFFB85042);
  static const Color arena = Color(0xFFE7E8D1);
  static const Color salvia = Color(0xFFA7BEAE);
  static const Color texto = Color(0xFF3A2E2A);

  bool _loadingOwner = false;

  Future<void> _openMap() async {
    final property = widget.property;
    String query;

    if (property.latitude != null && property.longitude != null) {
      query = '${property.latitude},${property.longitude}';
    } else {
      final regExp = RegExp(r'(-?\d+\.\d+),\s*(-?\d+\.\d+)');
      final match = regExp.firstMatch(property.location);
      if (match != null) {
        query = '${match.group(1)},${match.group(2)}';
      } else {
        query = Uri.encodeComponent(property.location);
      }
    }

    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir Google Maps')),
        );
      }
    }
  }

  Future<void> _editProperty() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PublishPropertyView(propertyToEdit: widget.property),
      ),
    );
    if (result == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteProperty() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: arena,
        title: const Text('¿Eliminar publicación?', style: TextStyle(color: texto, fontWeight: FontWeight.bold)),
        content: const Text(
          'Esta acción no se puede deshacer.',
          style: TextStyle(color: texto),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: texto)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: terracota,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await PropertyRepository().deleteProperty(widget.property.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Propiedad eliminada')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar propiedad: $e')),
          );
        }
      }
    }
  }

  Future<void> _contactOwner() async {
    setState(() => _loadingOwner = true);
    try {
      final ownerId = widget.property.ownerId;
      final owner = await PropertyRepository().getOwnerById(ownerId);
      if (!mounted) return;
      setState(() => _loadingOwner = false);
      if (owner == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró información del arrendador.')),
        );
        return;
      }
      final name = (owner['name'] ?? owner['nombre'] ?? 'Arrendador').toString();
      final email = (owner['email'] ?? '').toString();
      final phone = (owner['phone'] ?? owner['telefono'] ?? '').toString();

      showModalBottomSheet(
        context: context,
        backgroundColor: arena,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Contactar arrendador', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: texto)),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(backgroundColor: salvia, child: Icon(Icons.person, color: texto)),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: texto)),
                subtitle: Text([if (email.isNotEmpty) email, if (phone.isNotEmpty) phone].join(' • '), style: const TextStyle(color: texto)),
              ),
              const SizedBox(height: 16),
              if (phone.isNotEmpty)
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                        icon: const Icon(Icons.chat),
                        label: const Text('Enviar WhatsApp'),
                        onPressed: () async {
                          final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
                          final msg = Uri.encodeComponent('Hola, vi tu propiedad "${widget.property.title}" en NidoU y me interesa más información.');
                          final wa = Uri.parse('https://wa.me/$clean?text=$msg');
                          await launchUrl(wa, mode: LaunchMode.externalApplication);
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              if (email.isNotEmpty)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: terracota, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                        icon: const Icon(Icons.email),
                        label: const Text('Enviar correo'),
                        onPressed: () async {
                          final subject = Uri.encodeComponent('Interés en ${widget.property.title} - NidoU');
                          final mail = Uri.parse('mailto:$email?subject=$subject');
                          final launched = await launchUrl(mail);
                          if (!launched && mounted) {
                            await Clipboard.setData(ClipboardData(text: email));
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Correo copiado: $email')));
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Copiar correo',
                      icon: const Icon(Icons.copy, color: texto),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: email));
                        if (mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Correo copiado: $email')));
                        }
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _loadingOwner = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar datos del arrendador: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final property = widget.property;
    final price = '\$${property.price.toStringAsFixed(0)}/mes';
    final isOwner = uid != null && uid == property.ownerId;

    return FutureBuilder<DocumentSnapshot?>(
      future: uid != null ? FirebaseFirestore.instance.collection('users').doc(uid).get() : Future<DocumentSnapshot?>.value(null),
      builder: (context, snapshot) {
        final role = snapshot.data?.get('role')?.toString().toUpperCase() ?? '';
        final hideContact = isOwner || role == 'ARRENDADOR';
        return Scaffold(
          backgroundColor: arena,
          appBar: AppBar(
            title: const Text('Detalle de propiedad'),
            backgroundColor: terracota,
            foregroundColor: Colors.white,
            actions: [
              if (isOwner) ...[
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Editar propiedad',
                  onPressed: _editProperty,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Eliminar propiedad',
                  onPressed: _deleteProperty,
                ),
              ],
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 240, child: PropertyImage(urls: property.photos)),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(label: Text(property.type.toUpperCase()), backgroundColor: salvia, labelStyle: const TextStyle(color: texto, fontWeight: FontWeight.bold)),
                          Text(price, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: terracota)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(property.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: texto)),
                      const SizedBox(height: 6),
                      const Divider(height: 24),
                      const Text('Descripción', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: texto)),
                      const SizedBox(height: 6),
                      Text(property.description, style: const TextStyle(color: texto, height: 1.4)),
                      const SizedBox(height: 16),
                      if (property.services.isNotEmpty) ...[
                        const Text('Servicios incluidos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: texto)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: property.services.map((s) => Chip(label: Text(s), backgroundColor: Colors.white, labelStyle: const TextStyle(color: texto))).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Ubicación', style: TextStyle(fontWeight: FontWeight.bold, color: texto)),
                              const SizedBox(height: 4),
                              Text(property.location, style: const TextStyle(color: texto)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.directions_walk, size: 18, color: terracota),
                                  const SizedBox(width: 4),
                                  Text('${property.distanceMinutes} min a pie del campus', style: const TextStyle(color: texto)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(foregroundColor: terracota, side: const BorderSide(color: terracota)),
                                  onPressed: _openMap,
                                  icon: const Icon(Icons.map),
                                  label: const Text('Ver en el mapa'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: hideContact
              ? null
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: terracota, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: _loadingOwner ? null : _contactOwner,
                      icon: _loadingOwner
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.contact_phone),
                      label: Text(_loadingOwner ? 'Cargando contacto...' : 'Contactar arrendador'),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
