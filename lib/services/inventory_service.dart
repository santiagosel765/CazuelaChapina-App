import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/inventory_item.dart';
import '../models/inventory_movement_dto.dart';
import 'auth_service.dart';

class InventoryService {
  static const String _baseUrl = 'http://10.0.2.2:5151';
  final AuthService _authService = AuthService();

  Future<List<InventoryItem>> fetchItems() async {
    final token = await _authService.getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/api/Inventory'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => InventoryItem.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> createItem(InventoryItem item) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$_baseUrl/api/Inventory'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(item.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> updateItem(InventoryItem item) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    final response = await http.put(
      Uri.parse('$_baseUrl/api/Inventory/${item.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(item.toJson()),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteItem(int id) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('$_baseUrl/api/Inventory/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response.statusCode == 200;
  }

  Future<bool> _postMovement(
      int id, InventoryMovementDto dto, String action) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$_baseUrl/api/Inventory/$id/$action'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(dto.toJson()),
    );
    return response.statusCode == 200;
  }

  Future<bool> registerEntry(int id, InventoryMovementDto dto) =>
      _postMovement(id, dto, 'entry');

  Future<bool> registerExit(int id, InventoryMovementDto dto) =>
      _postMovement(id, dto, 'exit');

  Future<bool> registerWaste(int id, InventoryMovementDto dto) =>
      _postMovement(id, dto, 'waste');
}
