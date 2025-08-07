import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/combo.dart';
import 'auth_service.dart';

class ComboService {
  static const String _baseUrl = 'http://10.0.2.2:5151';
  final AuthService _authService = AuthService();

  Future<List<Combo>> fetchCombos() async {
    final token = await _authService.getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/api/Combos'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Combo.fromJson(e)).toList();
    }
    return [];
  }

  Future<Combo?> fetchCombo(int id) async {
    final token = await _authService.getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$_baseUrl/api/Combos/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Combo.fromJson(data);
    }
    return null;
  }

  Future<bool> createCombo(Combo combo) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$_baseUrl/api/Combos'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(combo.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> updateCombo(Combo combo) async {
    final token = await _authService.getToken();
    if (token == null || combo.id == null) return false;

    final response = await http.put(
      Uri.parse('$_baseUrl/api/Combos/${combo.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(combo.toJson()),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteCombo(int id) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('$_baseUrl/api/Combos/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response.statusCode == 200;
  }

  Future<bool> cloneCombo(int id) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$_baseUrl/api/Combos/$id/clone'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> activateCombo(int id) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$_baseUrl/api/Combos/$id/activate'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response.statusCode == 200;
  }

  Future<bool> deactivateCombo(int id) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$_baseUrl/api/Combos/$id/deactivate'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response.statusCode == 200;
  }
}
