import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_service.dart';

class ChatService {
  static const String _baseUrl = 'http://10.0.2.2:5151';
  final AuthService _authService = AuthService();

  Future<String?> sendMessage(String message) async {
    final token = await _authService.getToken();
    if (token == null) return null;

    final response = await http.post(
      Uri.parse('$_baseUrl/api/Chat'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'message': message}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['response'] as String?;
    }
    return null;
  }
}

