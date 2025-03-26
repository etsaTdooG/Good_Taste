import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/restaurant_model.dart';
import '../config/supabase_config.dart';

class SupabaseService extends ChangeNotifier {
  late final SupabaseClient _client;
  
  SupabaseClient get client => _client;

  // Initialize Supabase
  Future<void> initialize() async {
    try {
      // Initialize Supabase client
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
        debug: kDebugMode,
      );
      
      _client = Supabase.instance.client;
      debugPrint('Supabase initialized successfully');
      
      // Setup auth state change listener
      _client.auth.onAuthStateChange.listen(_handleAuthStateChange);
    } catch (e) {
      debugPrint('Error initializing Supabase: $e');
      rethrow;
    }
  }
  
  // Handle auth state changes
  void _handleAuthStateChange(AuthState state) {
    final session = state.session;
    if (session != null) {
      debugPrint('User authenticated: ${session.user.email}');
    } else {
      debugPrint('User signed out');
    }
    notifyListeners();
  }

  // Authentication methods
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final stopwatch = Stopwatch()..start();
      
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw AuthException('Failed to sign in', code: '400');
      }
      
      debugPrint('Sign in completed in ${stopwatch.elapsedMilliseconds}ms');
      stopwatch.stop();
    } on AuthException catch (e) {
      debugPrint('AuthException: ${e.message} (Code: ${e.code})');
      if (e.code == '400' && e.message.contains('Invalid login credentials')) {
        throw AuthException(
          'Email hoặc mật khẩu không chính xác. Vui lòng thử lại.', 
          code: e.code
        );
      }
      rethrow;
    } catch (e) {
      debugPrint('Error signing in: $e');
      rethrow;
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    try {
      final stopwatch = Stopwatch()..start();
      
      // Check if email already exists before attempting to sign up
      final bool emailExists = await checkEmailExists(email);
      if (emailExists) {
        throw AuthException(
          'Email này đã được đăng ký. Vui lòng sử dụng email khác hoặc đăng nhập.',
          code: 'email-already-in-use'
        );
      }
      
      // Sign up the user
      final authResponse = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'phone_number': phoneNumber,
        },
        emailRedirectTo: SupabaseConfig.webRedirectUrl,
      );
      
      // Check if user was created successfully
      if (authResponse.user == null) {
        throw AuthException('User registration failed', code: '400');
      }
      
      debugPrint('Auth signup completed in ${stopwatch.elapsedMilliseconds}ms');
      
      // The profile should be created automatically by the database trigger
      // If needed, we can update additional fields
      try {
        await _client.from('profiles').upsert({
          'id': authResponse.user!.id,
          'name': name,
          'phone_number': phoneNumber,
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'id');
        
        debugPrint('Profile creation completed in ${stopwatch.elapsedMilliseconds}ms');
      } catch (profileError) {
        debugPrint('Warning: Could not update profile details: $profileError');
        // We don't rethrow here because the user was already created
      }
      
      stopwatch.stop();
    } on AuthException catch (e) {
      debugPrint('AuthException during signup: ${e.message} (Code: ${e.code})');
      
      if (e.message.contains('User already registered')) {
        throw AuthException(
          'Email này đã được đăng ký. Vui lòng sử dụng email khác hoặc đăng nhập.',
          code: e.code
        );
      } else if (e.message.contains('row-level security policy') || e.message.contains('violates')) {
        // Handle RLS policy issue by using a more controlled approach
        await _retryProfileCreation();
      }
      
      rethrow;
    } catch (e) {
      debugPrint('Error signing up: $e');
      rethrow;
    }
  }
  
  Future<void> _retryProfileCreation() async {
    if (_client.auth.currentUser == null) return;
    
    try {
      // First check if profile already exists
      final existing = await _client.from('profiles')
          .select()
          .eq('id', _client.auth.currentUser!.id)
          .maybeSingle();
      
      if (existing == null) {
        // If not exists, create it with minimal info
        await _client.from('profiles').upsert({
          'id': _client.auth.currentUser!.id,
          'email': _client.auth.currentUser!.email,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        debugPrint('Successfully created profile in retry');
      }
    } catch (e) {
      debugPrint('Error in profile retry: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  bool get isAuthenticated => _client.auth.currentUser != null;
  
  User? get currentUser => _client.auth.currentUser;

  // Restaurant methods
  Future<List<Restaurant>> getRestaurants() async {
    try {
      final response = await _client
          .from('restaurants')
          .select('*, reviews(rating)')
          .order('created_at', ascending: false);
      
      return (response as List).map((json) => Restaurant.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting restaurants: $e');
      return [];
    }
  }

  Future<Restaurant?> getRestaurantById(String id) async {
    try {
      final response = await _client
          .from('restaurants')
          .select('*, reviews(*), dishes(*)')
          .eq('id', id)
          .single();
      
      return Restaurant.fromJson(response);
    } catch (e) {
      debugPrint('Error getting restaurant by ID: $e');
      return null;
    }
  }

  // Method to check if an email already exists in the database
  Future<bool> checkEmailExists(String email) async {
    try {
      // Query the auth.users table to check if the email exists
      final response = await _client.rpc(
        'check_if_email_exists',
        params: {'email_to_check': email},
      );
      
      // Response should be a boolean indicating if email exists
      return response as bool;
    } catch (e) {
      debugPrint('Error checking if email exists: $e');
      // If there's an error, we'll assume the email doesn't exist
      // to avoid blocking registration unnecessarily
      return false;
    }
  }
  
  // Reservation methods
  Future<List<dynamic>> getUserReservations() async {
    try {
      if (_client.auth.currentUser == null) {
        return [];
      }
      
      final response = await _client
          .from('reservations')
          .select('*, restaurants(name, image_url)')
          .eq('user_id', _client.auth.currentUser!.id)
          .order('date', ascending: false);
      
      return response;
    } catch (e) {
      debugPrint('Error getting user reservations: $e');
      return [];
    }
  }
  
  Future<bool> cancelReservation(String reservationId) async {
    try {
      // With our updated RLS policy, we can directly update the status to cancelled
      await _client
          .from('reservations')
          .update({'status': 'cancelled'})
          .eq('id', reservationId)
          .eq('user_id', _client.auth.currentUser!.id);
      
      return true;
    } catch (e) {
      debugPrint('Error cancelling reservation: $e');
      return false;
    }
  }
} 