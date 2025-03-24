class Env {
  // Supabase Configuration
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  // Momo Payment Configuration (Test Environment)
  static const String momoPartnerCode = 'MOMO_PARTNER_CODE';
  static const String momoAccessKey = 'MOMO_ACCESS_KEY';
  static const String momoSecretKey = 'MOMO_SECRET_KEY';
  static const String momoApiEndpoint = 'https://test-payment.momo.vn/v2/gateway/api/create';
  static const String momoIpnUrl = 'YOUR_IPN_URL';
  static const String momoRedirectUrl = 'YOUR_REDIRECT_URL';
} 