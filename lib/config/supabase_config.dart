import 'package:flutter/foundation.dart';

class SupabaseConfig {
  // Replace these values with your actual Supabase credentials
  // You need to get these values from your Supabase project dashboard
  // Go to https://supabase.com/dashboard, select your project, and get the URL and anon key
  static const String supabaseUrl = 'https://uvbpjpigxuzramfdvpbm.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV2YnBqcGlneHV6cmFtZmR2cGJtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEwNjAzMDgsImV4cCI6MjA1NjYzNjMwOH0.QJ_fKdhh9y-2BzkY13opbuETkTZ1dRMBLJO5kurkVhc';
  
  // Momo Payment Test Environment
  static const String momoPartnerCode = 'MOMO_PARTNER_CODE';
  static const String momoAccessKey = 'MOMO_ACCESS_KEY';
  static const String momoSecretKey = 'MOMO_SECRET_KEY';
  static const String momoEndpoint = kDebugMode 
      ? 'https://test-payment.momo.vn/v2/gateway/api/create'  // Test environment
      : 'https://payment.momo.vn/v2/gateway/api/create';      // Production environment
      
  // The redirect URL after payment
  static const String redirectUrl = 'YOUR_APP_SCHEME://payment-result';
  static const String ipnUrl = 'YOUR_SERVER_CALLBACK_URL'; // For server-side processing
  
  // Add the web redirect URL for authentication
  static const String webRedirectUrl = 'com.example.gota://auth-callback';
} 