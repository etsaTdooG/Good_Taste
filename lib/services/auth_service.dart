import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'supabase_service.dart';

class AuthService {
  final SupabaseClient _client = SupabaseService.client;
  
  // Check if user is logged in
  bool get isLoggedIn => _client.auth.currentUser != null;
  
  // Get current user ID
  String? get currentUserId => _client.auth.currentUser?.id;
  
  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Google Sign In process
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        return null;
      }
      
      // Get authentication data
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create Supabase credentials
      final idToken = googleAuth.idToken;
      
      if (idToken == null) {
        throw Exception('No ID Token found.');
      }
      
      // Sign in to Supabase with Google credentials
      final AuthResponse res = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      
      // Check if user exists in the database
      final user = res.user;
      if (user == null) {
        throw Exception('No user found after sign in.');
      }
      
      // Create or update user in the database
      await _createOrUpdateUser(
        user.id,
        googleUser.email,
        googleUser.displayName ?? '',
      );
      
      // Get user data from Supabase
      final userData = await _getUserData(user.id);
      return userData;
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
  
  // Get user data from database
  Future<UserModel?> _getUserData(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      return UserModel.fromJson(response);
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }
  
  // Get current user data
  Future<UserModel?> getCurrentUser() async {
    if (!isLoggedIn) return null;
    return await _getUserData(currentUserId!);
  }
  
  // Create or update user in database
  Future<void> _createOrUpdateUser(String id, String email, String name) async {
    try {
      await _client.from('users').upsert({
        'id': id,
        'email': email,
        'name': name,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error creating/updating user: $e');
    }
  }
  
  // Update user profile
  Future<void> updateUserProfile({
    required String name,
    String? phoneNumber,
  }) async {
    if (!isLoggedIn) return;
    
    try {
      await _client.from('users').update({
        'name': name,
        'phone_number': phoneNumber,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', currentUserId!);
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }
} 