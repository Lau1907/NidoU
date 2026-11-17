import 'dart:convert';
import 'package:flutter/material.dart';

/// Widget that displays a list of image URLs or base64 data strings,
/// or a single image via `imageUrl`.
class PropertyImage extends StatelessWidget {
  final List<String> urls;

  const PropertyImage({super.key, required this.urls});

  /// Constructor for a single image URL or base64 string.
  PropertyImage.single({super.key, required String imageUrl})
      : urls = imageUrl.isEmpty ? const [] : [imageUrl];

  Widget _buildImage(String source) {
    if (source.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Icon(Icons.photo, size: 64, color: Colors.grey)),
      );
    }
    if (source.startsWith('data:image')) {
      try {
        final base64Part = source.split(',').last;
        final bytes = base64Decode(base64Part);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
          ),
        );
      } catch (_) {
        return const SizedBox(
          height: 200,
          child: Center(child: Icon(Icons.broken_image, size: 48, color: Colors.grey)),
        );
      }
    }
    // Assume a network URL.
    return Image.network(
      source,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 200,
      errorBuilder: (_, __, ___) => const Center(
        child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Icon(Icons.photo, size: 64, color: Colors.grey)),
      );
    }
    if (urls.length == 1) {
      return _buildImage(urls.first);
    }
    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: urls.length,
        itemBuilder: (_, index) => _buildImage(urls[index]),
      ),
    );
  }
}
