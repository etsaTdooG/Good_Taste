class ReviewModel {
  final String id;
  final String userId;
  final String restaurantId;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String? userName;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.userName,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      userId: json['user_id'],
      restaurantId: json['restaurant_id'],
      rating: json['rating'].toDouble(),
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
      userName: json['user_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'restaurant_id': restaurantId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 