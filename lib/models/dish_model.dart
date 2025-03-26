
class Dish {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final List<String> categories;
  final bool isAvailable;
  final bool isPopular;
  
  Dish({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    this.categories = const [],
    this.isAvailable = true,
    this.isPopular = false,
  });
  
  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      imageUrl: json['image_url'],
      categories: json['categories'] != null
          ? List<String>.from(json['categories'])
          : [],
      isAvailable: json['is_available'] ?? true,
      isPopular: json['is_popular'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'categories': categories,
      'is_available': isAvailable,
      'is_popular': isPopular,
    };
  }
  
  @override
  String toString() => 'Dish(id: $id, name: $name, price: $price)';
} 