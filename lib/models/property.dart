class Property {
  final String id;
  final String title;
  final double price;
  final String location;
  final List<String> photos;

  const Property({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.photos,
  });
}
