class Restaurant {
  final String id;
  final String name;
  final String? imageUrl;
  final String? description;
  final String? address;
  final String? phone;
  final double averageRating;
  final int totalReviews;
  final DateTime createdAt;
  final String? openingHours;

  Restaurant({
    required this.id,
    required this.name,
    this.imageUrl,
    this.description,
    this.address,
    this.phone,
    required this.averageRating,
    required this.totalReviews,
    required this.createdAt,
    this.openingHours,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    // Handle case where reviews data is included in restaurant json
    double rating = 0.0;
    int reviews = 0;
    
    if (json.containsKey('reviews') && json['reviews'] != null) {
      final reviewsList = json['reviews'] as List?;
      if (reviewsList != null && reviewsList.isNotEmpty) {
        // Calculate average rating
        double sumRating = 0;
        for (final review in reviewsList) {
          sumRating += (review['rating'] as num).toDouble();
        }
        rating = sumRating / reviewsList.length;
        reviews = reviewsList.length;
      }
    }

    return Restaurant(
      id: json['id'].toString(),
      name: json['name'] as String,
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      averageRating: json['average_rating'] != null 
          ? (json['average_rating'] as num).toDouble() 
          : rating,
      totalReviews: json['total_reviews'] != null 
          ? (json['total_reviews'] as num).toInt() 
          : reviews,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
      openingHours: json['opening_hours'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'description': description,
      'address': address,
      'phone': phone,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'created_at': createdAt.toIso8601String(),
      'opening_hours': openingHours,
    };
  }
  
  // Create a new Restaurant instance with updated rating values
  Restaurant copyWithRating(double newAvgRating, int newTotalReviews) {
    return Restaurant(
      id: id,
      name: name,
      imageUrl: imageUrl,
      description: description,
      address: address,
      phone: phone,
      averageRating: newAvgRating,
      totalReviews: newTotalReviews,
      createdAt: createdAt,
      openingHours: openingHours,
    );
  }
} 