import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reservation_model.dart';
import 'supabase_service.dart';

class ReservationService {
  final SupabaseClient _client = SupabaseService.client;
  
  // Create a new reservation
  Future<String?> createReservation({
    required String userId,
    required String restaurantId,
    required DateTime date,
    required String time,
    required int numberOfPeople,
    String? notes,
  }) async {
    try {
      final response = await _client.from('reservations').insert({
        'user_id': userId,
        'restaurant_id': restaurantId,
        'date': date.toIso8601String().split('T')[0],
        'time': time,
        'number_of_people': numberOfPeople,
        'notes': notes,
        'status': 'Pending',
      }).select();
      
      if (response.isNotEmpty) {
        return response[0]['id'];
      }
      return null;
    } catch (e) {
      debugPrint('Error creating reservation: $e');
      return null;
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
    try {
      await _client.from('reservations').update({
        'date': date.toIso8601String().split('T')[0],
        'time': time,
        'number_of_people': numberOfPeople,
        'notes': notes,
      }).eq('id', reservationId);
      
      return true;
    } catch (e) {
      debugPrint('Error updating reservation: $e');
      return false;
    }
  }
  
  // Cancel a reservation
  Future<bool> cancelReservation(String reservationId) async {
    try {
      await _client.from('reservations').update({
        'status': 'Cancelled',
      }).eq('id', reservationId);
      
      return true;
    } catch (e) {
      debugPrint('Error cancelling reservation: $e');
      return false;
    }
  }
  
  // Get user reservations
  Future<List<ReservationModel>> getUserReservations(String userId) async {
    try {
      final response = await _client
          .from('reservations')
          .select('*, restaurants!inner(name)')
          .eq('user_id', userId)
          .order('date', ascending: false)
          .order('time', ascending: false);
      
      return response.map<ReservationModel>((json) {
        // Add restaurant name to reservation json
        json['restaurant_name'] = json['restaurants']['name'];
        return ReservationModel.fromJson(json);
      }).toList();
    } catch (e) {
      debugPrint('Error getting user reservations: $e');
      return [];
    }
  }
  
  // Get a specific reservation
  Future<ReservationModel?> getReservation(String reservationId) async {
    try {
      final response = await _client
          .from('reservations')
          .select('*, restaurants!inner(name)')
          .eq('id', reservationId)
          .single();
      
      response['restaurant_name'] = response['restaurants']['name'];
      return ReservationModel.fromJson(response);
    } catch (e) {
      debugPrint('Error getting reservation: $e');
      return null;
    }
  }
  
  // Subscribe to user reservations for real-time updates
  Stream<List<ReservationModel>> subscribeToUserReservations(String userId) {
    return _client
        .from('reservations')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((events) => events
            .map((event) => ReservationModel.fromJson(event))
            .toList());
  }
} 