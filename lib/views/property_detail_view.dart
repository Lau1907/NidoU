import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import '../models/property.dart';
import '../theme/app_colors.dart';

/// Pantalla de detalle de una propiedad.
/// Recibe un objeto [Property] y muestra:
///  * Carrusel de fotos con indicadores.
///  * Título, precio mensual formateado, tipo (badge) y distancia a pie.
///  * Descripción completa.
///  * Chips de servicios.
///  * Tarjeta de ubicación con botón "Ver en el mapa" que abre Google Maps.
///  * Botón principal "Contactar arrendador" que muestra un SnackBar.
class PropertyDetailView extends StatelessWidget {
  final Property property;

  const PropertyDetailView({Key? key, required this.property}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.arena,
      appBar: AppBar(
        backgroundColor: AppColors.arena,
        elevation: 0,
        title: const Text('Detalle de la propiedad'),
        foregroundColor: AppColors.texto,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _photoCarousel(),
                const SizedBox(height: 16),
                _headerInfo(),
                const SizedBox(height: 16),
                _descriptionSection(),
                const SizedBox(height: 16),
                _servicesChips(),
                const SizedBox(height: 16),
                _locationCard(context),
                const SizedBox(height: 24),
                _contactButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _photoCarousel() {
    return SizedBox(
      height: 240,
      child: PageView.builder(
        itemCount: property.photos.length,
        itemBuilder: (context, index) {
          final url = property.photos[index];
          return Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image, size: 48, color: AppColors.errorTexto),
            ),
          );
        },
      ),
    );
  }

  Widget _headerInfo() {
    final price = '\\$${property.price.toStringAsFixed(0)}/mes';
    final typeBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.salvia.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        property.type.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          property.title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.texto),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              price,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.terracota),
            ),
            const SizedBox(width: 12),
            typeBadge,
            const Spacer(),
            Text(
              '${property.distanceMinutes} min a pie',
              style: const TextStyle(fontSize: 14, color: AppColors.texto),
            ),
          ],
        ),
      ],
    );
  }

  Widget _descriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Descripción', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.texto)),
        const SizedBox(height: 4),
        Text(
          property.description,
          style: const TextStyle(fontSize: 14, color: AppColors.texto),
        ),
      ],
    );
  }

  Widget _servicesChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: property.services
          .map((s) => Chip(
                label: Text(s),
                backgroundColor: AppColors.salvia.withOpacity(0.3),
              ))
          .toList(),
    );
  }

  Widget _locationCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.blanco,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ubicación', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.texto)),
            const SizedBox(height: 8),
            Text(property.location, style: const TextStyle(fontSize: 14, color: AppColors.texto)),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _openInMaps(property.location),
                icon: const Icon(Icons.map),
                label: const Text('Ver en el mapa'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.terracota,
                  foregroundColor: AppColors.blanco,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openInMaps(String address) async {
    final query = Uri.encodeComponent(address);
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _contactButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Próximamente: contacto directo')),
          );
        },
        child: const Text('Contactar arrendador', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.terracota,
          foregroundColor: AppColors.blanco,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

