import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';

class ApiService {
  static const String baseUrl = 'https://online-voting-system-backend-server.onrender.com/api';
  static const String _secretKey = 'SECRET_KEY_12345'; // Must match server key

  String _generateSignature(String body) {
    final key = utf8.encode(_secretKey);
    final bytes = utf8.encode(body);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return base64.encode(digest.bytes);
  }

  Future<String> authenticate(String voterId) async {
    final url = Uri.parse('$baseUrl/auth/verify');
    try {
      final bodyMap = {
        'voterId': voterId,
        'faceHash': 'dummy-hash-value-from-client'
      };
      final String jsonBody = jsonEncode(bodyMap);
      final String signature = _generateSignature(jsonBody);

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Signature': signature,
        },
        body: jsonBody,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'];
      } else {
        throw Exception('Authentication failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error authenticating: $e');
      rethrow;
    }
  }

  // Returns a list of Map<String, String> with id and name
  Future<List<Map<String, String>>> getCandidates() async {
    // Hardcoded as there is no backend endpoint for candidates yet
    // In a real app, this would fetch from /vote/candidates
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network
    return [
      {'id': 'CANDIDATE_A', 'name': 'Alice Johnson', 'party': 'Progressive Party'},
      {'id': 'CANDIDATE_B', 'name': 'Bob Smith', 'party': 'Liberty Party'},
      {'id': 'CANDIDATE_C', 'name': 'Charlie Brown', 'party': 'Green Party'},
    ];
  }

  Future<void> castVote(String token, String candidateId) async {
    final url = Uri.parse('$baseUrl/vote/cast');
    try {
      final bodyMap = {
        'tokenUuid': token,
        'candidateId': candidateId,
      };
      final String jsonBody = jsonEncode(bodyMap);
      final String signature = _generateSignature(jsonBody);

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Signature': signature,
        },
        body: jsonBody,
      );

      if (response.statusCode != 200) {
         throw Exception('Failed to cast vote: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error casting vote: $e');
      rethrow;
    }
  }
}
