import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl = 'http://10.0.2.2:5151';

  Map<String, dynamic>? _decodedToken;

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Map<String, dynamic> _parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Token inválido');
    }
    final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    return jsonDecode(payload) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>?> _getDecodedToken() async {
    if (_decodedToken != null) return _decodedToken;
    final token = await getToken();
    if (token == null) return null;
    _decodedToken = _parseJwt(token);
    return _decodedToken;
  }

  Future<String?> getUsername() async {
    final payload = await _getDecodedToken();
    return payload?['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'] as String?;
  }

  Future<String?> getRole() async {
    final payload = await _getDecodedToken();
    return payload?['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] as String?;
  }

  Future<List<Map<String, dynamic>>> getPermissions() async {
    final payload = await _getDecodedToken();
    if (payload == null) return [];
    final perms = payload['permissions'];
    if (perms == null) return [];
    try {
      final List<dynamic> list = jsonDecode(perms);
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<bool> hasPermission(String module, String action) async {
    final permissions = await getPermissions();
    return permissions.any(
      (p) =>
          p['module'] == module && (p['actions'] as List<dynamic>).contains(action),
    );
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/Auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'] ?? data['accessToken'] ?? data['jwt'];
        if (token is String && token.isNotEmpty) {
          await _storeToken(token);
          _decodedToken = _parseJwt(token);
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> register(String username, String password, {String? role}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/Auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        if (role != null && role.isNotEmpty) 'role': role,
      }),
    );
    return response.statusCode == 200;
  }

  Future<void> registerFcmToken(String fcmToken) async {
    final token = await getToken();
    if (token == null) return;
    await http.post(
      Uri.parse('$_baseUrl/api/Notifications/register'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'token': fcmToken}),
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _decodedToken = null;
  }
}
