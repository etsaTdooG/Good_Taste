import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../config/supabase_config.dart';

class MomoPaymentService {
  static final MomoPaymentService _instance = MomoPaymentService._internal();
  factory MomoPaymentService() => _instance;

  MomoPaymentService._internal();

  Future<String?> createPaymentRequest({
    required String orderId,
    required double amount,
    required String orderInfo,
  }) async {
    try {
      // Convert amount to integer (VND)
      final int amountInt = (amount).round();
      
      // Create request data
      final Map<String, dynamic> requestData = {
        'partnerCode': SupabaseConfig.momoPartnerCode,
        'accessKey': SupabaseConfig.momoAccessKey,
        'requestId': orderId,
        'amount': amountInt,
        'orderId': orderId,
        'orderInfo': orderInfo,
        'redirectUrl': SupabaseConfig.redirectUrl,
        'ipnUrl': SupabaseConfig.ipnUrl,
        'requestType': 'captureWallet',
        'extraData': '',
        'lang': 'vi',
      };

      // Create signature
      final String signature = _createSignature(requestData);
      requestData['signature'] = signature;

      // Send request to Momo API
      final response = await http.post(
        Uri.parse(SupabaseConfig.momoEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        if (responseData['resultCode'] == 0) {
          // Success - return payment URL
          return responseData['payUrl'];
        } else {
          debugPrint('Momo payment error: ${responseData['message']}');
          return null;
        }
      } else {
        debugPrint('Momo payment API error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (error) {
      debugPrint('Error creating Momo payment request: $error');
      return null;
    }
  }

  Future<bool> launchPaymentUrl(String paymentUrl) async {
    try {
      final Uri uri = Uri.parse(paymentUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        debugPrint('Could not launch payment URL: $paymentUrl');
        return false;
      }
    } catch (error) {
      debugPrint('Error launching payment URL: $error');
      return false;
    }
  }

  WebViewController getWebViewControllerForPayment(String paymentUrl, Function(bool success) onPaymentComplete) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onUrlChange: (UrlChange change) {
            final url = change.url;
            if (url != null && url.contains('payment-result')) {
              // Extract status from URL
              final uri = Uri.parse(url);
              final String? resultCode = uri.queryParameters['resultCode'];
              
              // Check payment result
              final bool isSuccess = resultCode == '0' || resultCode == '9000';
              onPaymentComplete(isSuccess);
            }
          },
        ),
      );
    
    controller.loadRequest(Uri.parse(paymentUrl));
    return controller;
  }

  // Create HMAC SHA256 signature for Momo API request
  String _createSignature(Map<String, dynamic> data) {
    // Create raw signature
    final StringBuffer rawSignature = StringBuffer();
    rawSignature.write('accessKey=${SupabaseConfig.momoAccessKey}');
    rawSignature.write('&amount=${data['amount']}');
    rawSignature.write('&extraData=${data['extraData']}');
    rawSignature.write('&ipnUrl=${data['ipnUrl']}');
    rawSignature.write('&orderId=${data['orderId']}');
    rawSignature.write('&orderInfo=${data['orderInfo']}');
    rawSignature.write('&partnerCode=${SupabaseConfig.momoPartnerCode}');
    rawSignature.write('&redirectUrl=${data['redirectUrl']}');
    rawSignature.write('&requestId=${data['requestId']}');
    rawSignature.write('&requestType=${data['requestType']}');

    // Create HMAC SHA256 signature
    final key = utf8.encode(SupabaseConfig.momoSecretKey);
    final bytes = utf8.encode(rawSignature.toString());
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    
    return digest.toString();
  }

  // Generate a random string for order ID
  String generateOrderId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNumber = random.nextInt(1000000);
    return 'ORDER_$timestamp$randomNumber';
  }
} 