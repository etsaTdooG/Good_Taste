import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get error => _error;
  
  // Initialize the provider
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      if (_authService.isLoggedIn) {
        _user = await _authService.getCurrentUser();
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error initializing auth provider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _user = await _authService.signInWithGoogle();
      return _user != null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error signing in with Google: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _authService.signOut();
      _user = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error signing out: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Update user profile
  Future<bool> updateUserProfile({
    required String name,
    String? phoneNumber,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _authService.updateUserProfile(
        name: name,
        phoneNumber: phoneNumber,
      );
      
      // Refresh user data
      _user = await _authService.getCurrentUser();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating user profile: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 