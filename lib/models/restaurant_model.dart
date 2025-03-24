class RestaurantModel {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String description;
  final String imageUrl;
  final double? averageRating;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.description,
    required this.imageUrl,
    this.averageRating,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      description: json['description'],
      imageUrl: json['image_url'],
      averageRating: json['average_rating']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'description': description,
      'image_url': imageUrl,
      'average_rating': averageRating,
    };
  }
} 