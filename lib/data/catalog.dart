import 'package:flutter/material.dart';

String money(int cents) => '\$ ${(cents / 100).toStringAsFixed(2)}';

class Product {
  const Product(
    this.id,
    this.name,
    this.price,
    this.image,
    this.color,
    this.background,
  );
  final String id, name, image, color;
  final int price;
  final Color background;
  String get asset => 'assets/images/$image.png';
}

const products = [
  Product(
    'pathfinder',
    'Pathfinder LT-54',
    1200,
    'lamp_silver',
    'Silver',
    Color(0xFFF2F4F9),
  ),
  Product(
    'gile',
    'Gile LS-666',
    12000,
    'lamp_copper',
    'Copper',
    Color(0xFFFDF4F1),
  ),
  Product(
    'hobbit',
    'Hobbit LL-22',
    8500,
    'lamp_cream',
    'Yellow',
    Color(0xFFFFF8E7),
  ),
  Product(
    'classic',
    'Classic gilding table lamp',
    5000,
    'lamp_classic',
    'Silver',
    Color(0xFFF2F4FA),
  ),
  Product(
    'golden',
    'Classic gilding table lamp',
    7000,
    'lamp_gold',
    'Gold',
    Color(0xFFFFF3E4),
  ),
  Product(
    'nordic',
    'Nordic desk lamp',
    7000,
    'lamp_teal',
    'Teal',
    Color(0xFFEFF9FC),
  ),
];

Product productById(String id) =>
    products.firstWhere((p) => p.id == id, orElse: () => products.first);

class RoomConcept {
  const RoomConcept(this.id, this.name, this.image, this.description);
  final String id, name, image, description;
  String get asset => 'assets/images/$image.jpg';
}

const concepts = [
  RoomConcept(
    'pathfinder',
    'Pathfinder',
    'room_pathfinder',
    'A little light. A softer seat. A space that feels like you. Discover everyday comfort, thoughtfully put together.',
  ),
  RoomConcept(
    'minato',
    'Minato Georgsen',
    'room_pica',
    'Warm textures and timeless shapes bring a quiet balance to your living room.',
  ),
  RoomConcept(
    'monument',
    'Monument Enigmatic',
    'room_monument',
    'Simple silhouettes, natural light and room to breathe. Make space for the things you love.',
  ),
  RoomConcept(
    'pica',
    'Pica Atmosphere',
    'room_minato',
    'A considered collection for slow mornings and evenings at home.',
  ),
  RoomConcept(
    'onatoh',
    'Onatoh Annelle',
    'room_onatoh',
    'An inviting corner, made for conversation. Explore a fresh perspective on home.',
  ),
  RoomConcept(
    'nour',
    'Nourvukaiken',
    'room_nour',
    'Deep tones meet soft, natural materials in a calm and comfortable retreat.',
  ),
];

class ShopCategory {
  const ShopCategory(this.name, this.icon, this.count, this.accent);
  final String name;
  final IconData icon;
  final int count;
  final Color accent;
}

const categories = [
  ShopCategory('Light', Icons.light_outlined, 155, Color(0xFFD98CAA)),
  ShopCategory('Armchair', Icons.chair_outlined, 85, Color(0xFF497FB3)),
  ShopCategory('Sofa', Icons.weekend_outlined, 48, Color(0xFFDCB458)),
  ShopCategory('Bed', Icons.bed_outlined, 25, Color(0xFFD95E5E)),
  ShopCategory(
    'Bedside Table',
    Icons.bedroom_parent_outlined,
    71,
    Color(0xFF52B98A),
  ),
  ShopCategory(
    'Dressing Table',
    Icons.table_restaurant_outlined,
    56,
    Color(0xFF497FB3),
  ),
  ShopCategory('Wardrobe', Icons.door_sliding_outlined, 56, Color(0xFFD98CAA)),
];
