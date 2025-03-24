import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/env.dart';

class PaymentService {
  // Create a MoMo payment request
  Future<bool> createMomoPayment({
    required String orderId,
    required String orderInfo,
    required int amount,
    required Function(String paymentId) onSuccess,
  }) async {
    try {
      // Generate a random request ID
      final requestId = 'mm_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
      
      // Create payment request parameters
      final Map<String, dynamic> requestData = {
        'partnerCode': Env.momoPartnerCode,
        'partnerName': 'Good Taste Restaurant',
        'storeId': 'GOODTASTE',
        'requestId': requestId,
        'amount': amount,
        'orderId': orderId,
        'orderInfo': orderInfo,
        'redirectUrl': Env.momoRedirectUrl,
        'ipnUrl': Env.momoIpnUrl,
        'lang': 'vi',
        'extraData': '',
        'requestType': 'captureWallet',
      };
      
      // Create signature
      final signature = _createSignature(requestData);
      requestData['signature'] = signature;
      
      // For test environment, instead of actual API call, we'll simulate a successful payment
      // In a production environment, you would make an HTTP request to the Momo API
      
      // For demonstration, we'll launch a URL that would be similar to the Momo payment page
      final Uri momoUri = Uri.parse('${Env.momoApiEndpoint}?partnerCode=${Env.momoPartnerCode}&orderId=$orderId&amount=$amount');
      if (await canLaunchUrl(momoUri)) {
        await launchUrl(momoUri, mode: LaunchMode.externalApplication);
        
        // In a real implementation, you would wait for the callback from Momo
        // For demonstration, we'll simulate a successful callback
        await Future.delayed(const Duration(seconds: 5));
        onSuccess(requestId);
        return true;
      } else {
        debugPrint('Could not launch Momo payment URL');
        return false;
      }
    } catch (e) {
      debugPrint('Error creating Momo payment: $e');
      return false;
    }
  }
  
  // Generate a signature for the payment request
  String _createSignature(Map<String, dynamic> data) {
    // Sort all parameters by key (alphabetical order)
    final keys = data.keys.toList()..sort();
    final parametersContent = keys.map((key) => '$key=${data[key]}').join('&');
    
    // Create HMAC SHA256 signature
    final key = utf8.encode(Env.momoSecretKey);
    final bytes = utf8.encode(parametersContent);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    
    return digest.toString();
  }
  
  // Verify a payment response
  bool verifyPaymentResponse({
    required String requestId,
    required String orderId,
    required String amount,
    required String responseTime,
    required String transId,
    required String resultCode,
    required String message,
    required String signature,
  }) {
    // In a real implementation, you would verify the signature from the response
    // For demonstration, we'll assume the payment is verified if resultCode is "0" (success)
    return resultCode == '0';
  }
} 