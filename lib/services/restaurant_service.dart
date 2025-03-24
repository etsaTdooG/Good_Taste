import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/restaurant_model.dart';
import '../models/dish_model.dart';
import '../models/review_model.dart';
import 'supabase_service.dart';

class RestaurantService {
  final SupabaseClient _client = SupabaseService.client;
  
  // Get all restaurants
  Future<List<RestaurantModel>> getRestaurants() async {
    try {
      final response = await _client
          .from('restaurants')
          .select('*, (select avg(rating) from reviews where restaurant_id = restaurants.id) as average_rating')
          .order('name');
      
      return response.map<RestaurantModel>((json) => RestaurantModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting restaurants: $e');
      return [];
    }
  }
  
  // Get restaurant by ID
  Future<RestaurantModel?> getRestaurantById(String restaurantId) async {
    try {
      final response = await _client
          .from('restaurants')
          .select('*, (select avg(rating) from reviews where restaurant_id = restaurants.id) as average_rating')
          .eq('id', restaurantId)
          .single();
      
      return RestaurantModel.fromJson(response);
    } catch (e) {
      debugPrint('Error getting restaurant: $e');
      return null;
    }
  }
  
  // Get dishes by restaurant ID
  Future<List<DishModel>> getDishesByRestaurantId(String restaurantId) async {
    try {
      final response = await _client
          .from('dishes')
          .select()
          .eq('restaurant_id', restaurantId)
          .order('name');
      
      return response.map<DishModel>((json) => DishModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting dishes: $e');
      return [];
    }
  }
  
  // Get reviews by restaurant ID
  Future<List<ReviewModel>> getReviewsByRestaurantId(String restaurantId) async {
    try {
      final response = await _client
          .from('reviews')
          .select('*, users!inner(name)')
          .eq('restaurant_id', restaurantId)
          .order('created_at', ascending: false);
      
      return response.map<ReviewModel>((json) {
        // Add the user name to the review json
        json['user_name'] = json['users']['name'];
        return ReviewModel.fromJson(json);
      }).toList();
    } catch (e) {
      debugPrint('Error getting reviews: $e');
      return [];
    }
  }
  
  // Subscribe to reviews for real-time updates
  Stream<List<ReviewModel>> subscribeToRestaurantReviews(String restaurantId) {
    return _client
        .from('reviews')
        .stream(primaryKey: ['id'])
        .eq('restaurant_id', restaurantId)
        .map((events) => events
            .map((event) => ReviewModel.fromJson(event))
            .toList());
  }
  
  // Add a new review
  Future<bool> addReview({
    required String userId,
    required String restaurantId,
    required double rating,
    required String comment,
  }) async {
    try {
      await _client.from('reviews').insert({
        'user_id': userId,
        'restaurant_id': restaurantId,
        'rating': rating,
        'comment': comment,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      return true;
    } catch (e) {
      debugPrint('Error adding review: $e');
      return false;
    }
  }
} 