import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

class HmacInterceptor extends Interceptor {
  // In a real app, store this in SecureStorage or obscure it via JNI/C++ code.
  static const String _secretKey = "SECRET_KEY_12345"; 

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 1. Get Body
    final dynamic data = options.data;
    String bodyString = "";

    if (data != null) {
       if (data is Map || data is List) {
         bodyString = jsonEncode(data);
       } else {
         bodyString = data.toString();
       }
    }

    // 2. Calculate HMAC-SHA256
    final key = utf8.encode(_secretKey);
    final bytes = utf8.encode(bodyString);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    
    // 3. Add Header
    options.headers['X-Signature'] = digest.toString();
    
    // Also ensuring content-type is json
    options.contentType = Headers.jsonContentType;

    super.onRequest(options, handler);
  }
}
