class Review {
  final String id;
  final String restaurantId;
  final String userId;
  final String? userName;
  final double rating;
  final String? comment;
  final DateTime createdAt;
  
  Review({
    required this.id,
    required this.restaurantId,
    required this.userId,
    this.userName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });
  
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      restaurantId: json['restaurant_id'],
      userId: json['user_id'],
      userName: json['user_name'],
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'user_id': userId,
      'user_name': userName,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  @override
  String toString() => 'Review(id: $id, rating: $rating)';
} 