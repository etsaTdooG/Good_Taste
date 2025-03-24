import 'package:flutter/foundation.dart';
import '../models/reservation_model.dart';
import '../services/reservation_service.dart';
import '../services/payment_service.dart';

class ReservationProvider extends ChangeNotifier {
  final ReservationService _reservationService = ReservationService();
  final PaymentService _paymentService = PaymentService();
  
  List<ReservationModel> _userReservations = [];
  ReservationModel? _currentReservation;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<ReservationModel> get userReservations => _userReservations;
  ReservationModel? get currentReservation => _currentReservation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Fetch user reservations
  Future<void> fetchUserReservations(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _userReservations = await _reservationService.getUserReservations(userId);
      
      // Subscribe to real-time updates
      _subscribeToUserReservations(userId);
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching user reservations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Subscribe to real-time updates for user reservations
  void _subscribeToUserReservations(String userId) {
    _reservationService
        .subscribeToUserReservations(userId)
        .listen((updatedReservations) {
      // Update reservations with real-time data
      _userReservations = updatedReservations;
      notifyListeners();
    });
  }
  
  // Create a new reservation
  Future<bool> createReservation({
    required String userId,
    required String restaurantId,
    required DateTime date,
    required String time,
    required int numberOfPeople,
    String? notes,
    required String restaurantName,
    required int amount,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Create the reservation in Supabase
      final reservationId = await _reservationService.createReservation(
        userId: userId,
        restaurantId: restaurantId,
        date: date,
        time: time,
        numberOfPeople: numberOfPeople,
        notes: notes,
      );
      
      if (reservationId == null) {
        throw Exception('Failed to create reservation');
      }
      
      // Process payment with Momo
      final orderInfo = 'Reservation at $restaurantName - $numberOfPeople people on ${date.toIso8601String().split('T')[0]} at $time';
      
      final paymentSuccess = await _paymentService.createMomoPayment(
        orderId: reservationId,
        orderInfo: orderInfo,
        amount: amount,
        onSuccess: (paymentId) async {
          // Update reservation status after successful payment
          await _reservationService.updateReservation(
            reservationId: reservationId,
            date: date,
            time: time,
            numberOfPeople: numberOfPeople,
            notes: notes,
          );
          
          // Get the updated reservation
          _currentReservation = await _reservationService.getReservation(reservationId);
          notifyListeners();
        },
      );
      
      return paymentSuccess;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating reservation: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Update an existing reservation
  Future<bool> updateReservation({
    required String reservationId,
    required DateTime date,
    required String time,
    required int numberOfPeople,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final success = await _reservationService.updateReservation(
        reservationId: reservationId,
        date: date,
        time: time,
        numberOfPeople: numberOfPeople,
        notes: notes,
      );
      
      if (success) {
        // Get the updated reservation
        _currentReservation = await _reservationService.getReservation(reservationId);
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating reservation: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Cancel a reservation
  Future<bool> cancelReservation(String reservationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final success = await _reservationService.cancelReservation(reservationId);
      
      if (success) {
        // Get the updated reservation
        _currentReservation = await _reservationService.getReservation(reservationId);
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error cancelling reservation: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Get a specific reservation
  Future<void> getReservation(String reservationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _currentReservation = await _reservationService.getReservation(reservationId);
    } catch (e) {
      _error = e.toString();
      debugPrint('Error getting reservation: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 