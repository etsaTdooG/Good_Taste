# Momo Payment Integration Guide

This guide explains how to set up Momo payment integration for the Good Taste restaurant reservation app.

## 1. Create a Momo Business Account

1. Go to [Momo Business](https://business.momo.vn/) and sign up for a business account.
2. Complete the verification process and provide all required business documents.
3. Once approved, log in to your Momo Business dashboard.

## 2. Set Up Test Environment

Before going live, use the Momo test environment:

1. In your Momo dashboard, go to **Developer** > **Test Environment**.
2. Request access to the test environment if not already available.
3. Generate test API credentials including:
   - Partner Code
   - Access Key
   - Secret Key

## 3. Configure Web/App-to-App Integration

1. In the Momo dashboard, go to **Integration Settings**.
2. Select **Web/App-to-App Integration**.
3. Configure the following:
   - **IPN URL (Instant Payment Notification)**: This is the URL Momo will call to notify your server about payment status.
   - **Redirect URL**: This is where users will be redirected after completing or canceling a payment.

## 4. Update Flutter App Configuration

Update the `lib/constants/env.dart` file with your Momo credentials:

```dart
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
```

## 5. Implement Payment Request in the App

The payment flow should have these components:

### 5.1. Create Payment Request

This happens in the `PaymentService` class:

```dart
Future<Map<String, dynamic>> createMomoPaymentRequest(
    String reservationId, 
    double amount, 
    String restaurantName
) async {
  // Generate unique order ID
  final orderId = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';
  
  // Create request parameters
  final requestId = 'RQ_${DateTime.now().millisecondsSinceEpoch}';
  final orderInfo = 'Reservation at $restaurantName';
  final extraData = '';
  
  // Convert amount to integer (Momo requires amount in VND without decimals)
  final amountInt = (amount * 1).round();
  
  // Create raw signature
  final rawSignature = 'accessKey=${Env.momoAccessKey}&amount=$amountInt&extraData=$extraData&ipnUrl=${Env.momoIpnUrl}&orderId=$orderId&orderInfo=$orderInfo&partnerCode=${Env.momoPartnerCode}&redirectUrl=${Env.momoRedirectUrl}&requestId=$requestId&requestType=captureWallet';
  
  // Generate HMAC SHA256 signature
  final signature = generateHmacSha256(rawSignature, Env.momoSecretKey);
  
  // Create payment request body
  final requestBody = {
    'partnerCode': Env.momoPartnerCode,
    'accessKey': Env.momoAccessKey,
    'requestId': requestId,
    'amount': amountInt,
    'orderId': orderId,
    'orderInfo': orderInfo,
    'redirectUrl': Env.momoRedirectUrl,
    'ipnUrl': Env.momoIpnUrl,
    'extraData': extraData,
    'requestType': 'captureWallet',
    'signature': signature,
    'lang': 'en'
  };
  
  // Send request to Momo API
  final response = await http.post(
    Uri.parse(Env.momoApiEndpoint),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(requestBody),
  );
  
  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    // Store payment information in your database
    await _storePaymentInfo(reservationId, orderId, requestId, amount);
    return responseData;
  } else {
    throw Exception('Failed to create Momo payment: ${response.body}');
  }
}
```

### 5.2. Helper Functions

Include these helper functions:

```dart
String generateHmacSha256(String data, String secretKey) {
  final key = utf8.encode(secretKey);
  final bytes = utf8.encode(data);
  final hmacSha256 = Hmac(sha256, key);
  final digest = hmacSha256.convert(bytes);
  return digest.toString();
}

Future<void> _storePaymentInfo(
    String reservationId, 
    String orderId, 
    String requestId, 
    double amount
) async {
  try {
    final user = _authService.currentUser;
    if (user == null) throw Exception('User not authenticated');
    
    await _supabaseService.client.from('payments').insert({
      'reservation_id': reservationId,
      'user_id': user.id,
      'order_id': orderId,
      'request_id': requestId,
      'amount': amount,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    });
  } catch (e) {
    print('Error storing payment info: $e');
    throw Exception('Failed to store payment information');
  }
}
```

### 5.3. Handling Payment Response

After receiving the payment response from Momo:

```dart
void handlePaymentResponse(Map<String, dynamic> response) {
  if (response.containsKey('payUrl')) {
    final payUrl = response['payUrl'];
    // Open the payment URL in a WebView or external browser
    launchUrl(Uri.parse(payUrl), mode: LaunchMode.externalApplication);
  } else {
    throw Exception('Invalid payment response: No payUrl found');
  }
}
```

## 6. Set Up Payment Callback Handling

### 6.1. Create a Backend Endpoint for IPN URL

You need a server endpoint to handle Momo's IPN callbacks:

```javascript
// Example using Node.js with Express
app.post('/api/momo-callback', async (req, res) => {
  try {
    const {
      partnerCode,
      orderId,
      requestId,
      amount,
      orderInfo,
      orderType,
      transId,
      resultCode,
      message,
      payType,
      responseTime,
      extraData,
      signature
    } = req.body;
    
    // Verify the signature
    // ... signature verification code ...
    
    // Update payment status in your database
    if (resultCode === '0') {
      // Payment successful
      // Update payment status to 'completed'
      // Update reservation status to 'confirmed'
    } else {
      // Payment failed
      // Update payment status to 'failed'
    }
    
    // Send response to Momo
    res.status(200).json({
      status: 'ok',
      message: 'Received payment notification'
    });
  } catch (error) {
    console.error('Error processing Momo callback:', error);
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
});
```

### 6.2. Handle Redirect URL in the App

Your app should handle the redirect URL when the user returns from the Momo app:

```dart
void initRedirectUrlHandling() {
  // Handle deep link
  uriLinkStream.listen((Uri? uri) {
    if (uri != null) {
      handleDeepLink(uri);
    }
  }, onError: (error) {
    print('Error handling deep link: $error');
  });
}

void handleDeepLink(Uri uri) {
  // Extract query parameters
  final queryParams = uri.queryParameters;
  final orderId = queryParams['orderId'];
  final resultCode = queryParams['resultCode'];
  
  if (orderId != null && resultCode != null) {
    // Check payment status
    if (resultCode == '0') {
      // Payment successful
      _updatePaymentStatus(orderId, 'completed');
      _showPaymentSuccessUI();
    } else {
      // Payment failed
      _updatePaymentStatus(orderId, 'failed');
      _showPaymentFailedUI(resultCode, queryParams['message'] ?? 'Payment failed');
    }
  }
}

Future<void> _updatePaymentStatus(String orderId, String status) async {
  try {
    final user = _authService.currentUser;
    if (user == null) throw Exception('User not authenticated');
    
    // Update payment status in your database
    await _supabaseService.client.from('payments')
      .update({'status': status})
      .eq('order_id', orderId)
      .eq('user_id', user.id);
    
    // If payment is completed, update reservation status
    if (status == 'completed') {
      // Get reservation ID from payment record
      final payment = await _supabaseService.client.from('payments')
        .select('reservation_id')
        .eq('order_id', orderId)
        .single();
      
      if (payment != null && payment['reservation_id'] != null) {
        await _reservationService.updateReservationStatus(
          payment['reservation_id'], 
          'Confirmed'
        );
      }
    }
  } catch (e) {
    print('Error updating payment status: $e');
  }
}
```

## 7. Create Database Table for Payments

Execute the following SQL in your Supabase SQL Editor:

```sql
-- Create payments table
CREATE TABLE payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  reservation_id UUID REFERENCES reservations(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  order_id TEXT NOT NULL,
  request_id TEXT NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  transaction_id TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on payments table
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for payments
CREATE POLICY "Users can view their own payments" 
ON payments FOR SELECT 
USING (auth.uid() = user_id);

-- Create update trigger for payments
CREATE TRIGGER update_payments_updated_at
BEFORE UPDATE ON payments
FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_column();
```

## 8. Testing the Payment Integration

1. Set up a test account in the Momo sandbox environment.
2. Make a reservation in your app and proceed to payment.
3. Use the test account credentials to complete the payment.
4. Verify that your app correctly handles the payment response.
5. Check that the payment status is updated in your database.
6. Confirm that the reservation status is updated to "Confirmed".

## 9. Going Live

Once your testing is complete and you're ready to go live:

1. In your Momo dashboard, request to move to the production environment.
2. Update your app configuration with the production credentials.
3. Update the IPN URL and Redirect URL to your production endpoints.
4. Perform a final round of testing with the production environment.

## 10. Troubleshooting

- **Payment Creation Fails**: Verify that your signature generation is correct.
- **IPN Not Received**: Check that your IPN URL is publicly accessible and correctly configured.
- **Redirect Not Working**: Ensure your app's deep linking is properly set up.
- **Payment Status Not Updated**: Verify the IPN handler is correctly updating your database.

## 11. Security Considerations

- Always verify the payment signature in your IPN handler.
- Store sensitive keys securely, never in client-side code.
- Implement proper error handling and logging.
- Use HTTPS for all API calls and callbacks.
- Validate all input data before processing.

For more information, refer to the [official Momo documentation](https://developers.momo.vn/). 