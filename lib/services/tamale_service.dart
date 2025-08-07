import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/catalog_item.dart';
import '../models/tamale.dart';
import 'auth_service.dart';

class TamaleService {
  static const String _baseUrl = 'http://10.0.2.2:5151';
  final AuthService _authService = AuthService();

  Future<List<Tamale>> fetchTamales() async {
    final token = await _authService.getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/api/Tamales'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Tamale.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> createTamale(Tamale tamale) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$_baseUrl/api/Tamales'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(tamale.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> updateTamale(Tamale tamale) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    final response = await http.put(
      Uri.parse('$_baseUrl/api/Tamales/${tamale.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(tamale.toJson()),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteTamale(int id) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('$_baseUrl/api/Tamales/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response.statusCode == 200;
  }

  Future<List<CatalogItem>> _fetchCatalog(String endpoint) async {
    final token = await _authService.getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => CatalogItem.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<CatalogItem>> getTamaleTypes() => _fetchCatalog('api/TamaleTypes');
  Future<List<CatalogItem>> getFillings() => _fetchCatalog('api/Fillings');
  Future<List<CatalogItem>> getWrappers() => _fetchCatalog('api/Wrappers');
  Future<List<CatalogItem>> getSpiceLevels() => _fetchCatalog('api/SpiceLevels');
}
