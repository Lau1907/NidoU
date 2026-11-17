import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/property.dart';
import '../repositories/property_repository.dart';

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

  int _currentPage = 0;
  bool _loadingOwner = false;

  Future<void> _openMap() async {
    final query = Uri.encodeComponent(widget.property.location);
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir Google Maps')),
        );
      }
    }
  }

  Future<void> _contactOwner() async {
    setState(() => _loadingOwner = true);
    try {
      final owner = await PropertyRepository().getOwnerById(widget.property.ownerId);
      if (!mounted) return;
      setState(() => _loadingOwner = false);

      if (owner == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró información del arrendador.')),
        );
        return;
      }

      final name = (owner['name'] ?? owner['nombre'] ?? 'Arrendador NidoU').toString();
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
              Text(
                'Contactar arrendador',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: texto),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: salvia,
                  child: Icon(Icons.person, color: texto),
                ),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: texto)),
                subtitle: Text(
                  [if (email.isNotEmpty) email, if (phone.isNotEmpty) phone].join(' • '),
                  style: const TextStyle(color: texto),
                ),
              ),
              const SizedBox(height: 16),
              if (phone.isNotEmpty) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.chat),
                    label: const Text('Enviar WhatsApp'),
                    onPressed: () async {
                      final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
                      final msg = Uri.encodeComponent(
                        "Hola, vi tu propiedad '${widget.property.title}' en NidoU y me interesa más información.",
                      );
                      final waUrl = Uri.parse('https://wa.me/$cleanPhone?text=$msg');
                      await launchUrl(waUrl, mode: LaunchMode.externalApplication);
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
              if (email.isNotEmpty)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: terracota,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.email),
                        label: const Text('Enviar correo'),
                        onPressed: () async {
                          final subject = Uri.encodeComponent('Interés en ${widget.property.title} - NidoU');
                          final mailUri = Uri.parse('mailto:$email?subject=$subject');
                          final launched = await launchUrl(mailUri);
                          if (!launched && ctx.mounted) {
                            await Clipboard.setData(ClipboardData(text: email));
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Correo copiado: $email')),
                            );
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
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Correo copiado: $email')),
                          );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos del arrendador: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    final price = '\$${property.price.toStringAsFixed(0)}/mes';

    return Scaffold(
      backgroundColor: arena,
      appBar: AppBar(
        title: const Text('Detalle de propiedad'),
        backgroundColor: terracota,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 240,
              child: property.photos.isEmpty
                  ? Container(
                      color: salvia.withValues(alpha: 0.3),
                      child: const Center(child: Icon(Icons.home_work, size: 64, color: texto)),
                    )
                  : Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        PageView.builder(
                          itemCount: property.photos.length,
                          onPageChanged: (i) => setState(() => _currentPage = i),
                          itemBuilder: (_, i) => Image.network(
                            property.photos[i],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => Container(
                              color: salvia.withValues(alpha: 0.3),
                              child: const Center(
                                child: Icon(Icons.broken_image, size: 48, color: texto),
                              ),
                            ),
                          ),
                        ),
                        if (property.photos.length > 1)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                property.photos.length,
                                (i) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentPage == i ? terracota : Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        label: Text(property.type.toUpperCase()),
                        backgroundColor: salvia,
                        labelStyle: const TextStyle(color: texto, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        price,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: terracota),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: texto),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.directions_walk, size: 18, color: terracota),
                      const SizedBox(width: 4),
                      Text('${property.distanceMinutes} min a pie del campus',
                          style: const TextStyle(color: texto)),
                    ],
                  ),
                  const Divider(height: 24),
                  const Text('Descripción',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: texto)),
                  const SizedBox(height: 6),
                  Text(property.description, style: const TextStyle(color: texto, height: 1.4)),
                  const SizedBox(height: 16),
                  if (property.services.isNotEmpty) ...[
                    const Text('Servicios incluidos',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: texto)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: property.services
                          .map((s) => Chip(
                                label: Text(s),
                                backgroundColor: Colors.white,
                                labelStyle: const TextStyle(color: texto),
                              ))
                          .toList(),
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
                          const Text('Ubicación',
                              style: TextStyle(fontWeight: FontWeight.bold, color: texto)),
                          const SizedBox(height: 4),
                          Text(property.location, style: const TextStyle(color: texto)),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: terracota,
                                side: const BorderSide(color: terracota),
                              ),
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: terracota,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _loadingOwner ? null : _contactOwner,
            icon: _loadingOwner
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.contact_phone),
            label: Text(_loadingOwner ? 'Cargando contacto...' : 'Contactar arrendador'),
          ),
        ),
      ),
    );
  }
}