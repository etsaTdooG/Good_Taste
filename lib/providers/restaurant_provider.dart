import 'package:flutter/foundation.dart';
import '../models/restaurant_model.dart';
import '../models/dish_model.dart';
import '../models/review_model.dart';
import '../services/restaurant_service.dart';

class RestaurantProvider extends ChangeNotifier {
  final RestaurantService _restaurantService = RestaurantService();
  
  List<RestaurantModel> _restaurants = [];
  RestaurantModel? _selectedRestaurant;
  List<DishModel> _dishes = [];
  List<ReviewModel> _reviews = [];
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<RestaurantModel> get restaurants => _restaurants;
  RestaurantModel? get selectedRestaurant => _selectedRestaurant;
  List<DishModel> get dishes => _dishes;
  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Fetch all restaurants
  Future<void> fetchRestaurants() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _restaurants = await _restaurantService.getRestaurants();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching restaurants: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Select a restaurant and fetch its details
  Future<void> selectRestaurant(String restaurantId) async {
    _isLoading = true;
    _error = null;
    _selectedRestaurant = null;
    _dishes = [];
    _reviews = [];
    notifyListeners();
    
    try {
      // Get restaurant details
      _selectedRestaurant = await _restaurantService.getRestaurantById(restaurantId);
      
      // Get dishes for the restaurant
      _dishes = await _restaurantService.getDishesByRestaurantId(restaurantId);
      
      // Get reviews for the restaurant
      _reviews = await _restaurantService.getReviewsByRestaurantId(restaurantId);
      
      // Subscribe to real-time updates for reviews
      _subscribeToReviews(restaurantId);
    } catch (e) {
      _error = e.toString();
      debugPrint('Error selecting restaurant: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Subscribe to real-time updates for reviews
  void _subscribeToReviews(String restaurantId) {
    _restaurantService
        .subscribeToRestaurantReviews(restaurantId)
        .listen((updatedReviews) {
      // Update reviews with real-time data
      _reviews = updatedReviews;
      notifyListeners();
    });
  }
  
  // Add a review
  Future<bool> addReview({
    required String userId,
    required String restaurantId,
    required double rating,
    required String comment,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final success = await _restaurantService.addReview(
        userId: userId,
        restaurantId: restaurantId,
        rating: rating,
        comment: comment,
      );
      
      if (success) {
        // Real-time subscription will update the reviews
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error adding review: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 