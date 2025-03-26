# Momo Payment Integration Guide

This guide explains how to integrate Momo payment gateway with your Flutter app.

## Overview

The Momo integration in this app uses the following components:

1. **Momo API Client**: Handles communication with Momo's payment API
2. **WebView Integration**: For displaying the payment interface
3. **URL Scheme Handling**: For receiving payment callbacks

## Updates for Latest Flutter Version

This integration has been updated to work with the latest Flutter versions:

1. **WebView Changes**: Updated to use `onUrlChange` instead of the deprecated `onPageFinished` callback
2. **URL Launcher**: Using proper URI handling with the latest URL launcher APIs
3. **Error Handling**: Improved error handling throughout the payment flow
4. **Crypto Libraries**: Using the latest crypto libraries for secure HMAC generation

## Step 1: Get Momo Test Credentials

To use Momo's test environment, you need to:

1. Register at [Momo Business Portal](https://business.momo.vn/)
2. Create a test merchant and request test credentials
3. You'll receive:
   - Partner Code
   - Access Key
   - Secret Key

## Step 2: Configure Your App

Update your configuration in `lib/config/supabase_config.dart`:

```dart
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
```

## Step 3: Set Up URL Scheme Handling

### For Android

Update your `android/app/src/main/AndroidManifest.xml`:

```xml
<activity
    android:name=".MainActivity"
    android:launchMode="singleTask">
    <!-- ... other activity attributes ... -->
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="YOUR_APP_SCHEME" android:host="payment-result" />
    </intent-filter>
</activity>
```

### For iOS

Update your `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>YOUR_BUNDLE_ID</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_APP_SCHEME</string>
        </array>
    </dict>
</array>
```

## Step 4: Create a Payment Request

To create a payment request, use the `MomoPaymentService` class:

```dart
final momoService = MomoPaymentService();

// Generate an order ID
final orderId = momoService.generateOrderId();

// Create the payment request
final paymentUrl = await momoService.createPaymentRequest(
  orderId: orderId,
  amount: 100000, // Amount in VND
  orderInfo: 'Payment for reservation #123',
);

if (paymentUrl != null) {
  // Open the payment URL
  await momoService.launchPaymentUrl(paymentUrl);
} else {
  // Handle error
  print('Failed to create payment request');
}
```

## Step 5: Handle Payment Results

You can handle payment results in two ways:

### Using URL Scheme

When the payment is completed, Momo will redirect to your app using the redirect URL you provided. You can extract the payment result from the URL:

```dart
// In your app's deep link handler
void handleDeepLink(String url) {
  if (url.contains('payment-result')) {
    final uri = Uri.parse(url);
    final resultCode = uri.queryParameters['resultCode'];
    
    // resultCode == '0' or '9000' means success
    final isSuccess = resultCode == '0' || resultCode == '9000';
    
    if (isSuccess) {
      // Payment succeeded, update reservation status
    } else {
      // Payment failed
    }
  }
}
```

### Using WebView

If you're using a WebView for payment, you can monitor URL changes to detect payment completion:

```dart
WebViewController controller = momoService.getWebViewControllerForPayment(
  paymentUrl,
  (bool success) {
    if (success) {
      // Payment succeeded
    } else {
      // Payment failed
    }
  },
);
```

## Step 6: Update Reservation Status

After a successful payment, update the reservation status:

```dart
await supabaseService.updateReservationStatus(
  reservationId: reservationId,
  status: ReservationStatus.confirmed,
  paymentId: orderId,
);
```

## Testing the Integration

1. Use the test environment credentials
2. Test with special test card numbers provided by Momo:
   - Card Number: 9704 0000 0000 0018
   - Expiry: 03/07
   - CVV: 603
   - OTP: OTP

## Common Issues and Troubleshooting

1. **Signature Mismatch Error**:
   - Ensure your Secret Key is correct
   - Check that the signature creation follows Momo's requirements
   
2. **Redirect URL Not Working**:
   - Verify URL scheme configuration in AndroidManifest.xml and Info.plist
   - Ensure the app is properly registered to handle the URL scheme

3. **Payment Always Failing**:
   - When using test credentials, only use the test card numbers provided by Momo
   - Ensure you're using test environment URLs

4. **API Connection Issues**:
   - Check internet connectivity
   - Verify if Momo's servers are operational

## Production Considerations

When moving to production:

1. Replace test credentials with production credentials
2. Update the endpoint URL to the production URL
3. Implement proper security measures for payment data
4. Set up a server endpoint for IPN (Instant Payment Notification) to receive asynchronous payment updates from Momo

## Additional Resources

- [Momo Developer Documentation](https://developers.momo.vn/)
- [Momo API References](https://developers.momo.vn/v3/docs/payment/api/) 