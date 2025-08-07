import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/beverage.dart';
import '../models/catalog_item.dart';
import 'auth_service.dart';

class BeverageService {
  static const String _baseUrl = 'http://10.0.2.2:5151';
  final AuthService _authService = AuthService();

  Future<List<Beverage>> fetchBeverages() async {
    final token = await _authService.getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/api/Beverages'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Beverage.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> createBeverage(Beverage beverage) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$_baseUrl/api/Beverages'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(beverage.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> updateBeverage(Beverage beverage) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    final response = await http.put(
      Uri.parse('$_baseUrl/api/Beverages/${beverage.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(beverage.toJson()),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteBeverage(int id) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('$_baseUrl/api/Beverages/$id'),
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

  Future<List<CatalogItem>> getBeverageTypes() => _fetchCatalog('api/BeverageTypes');
  Future<List<CatalogItem>> getBeverageSizes() => _fetchCatalog('api/BeverageSizes');
  Future<List<CatalogItem>> getSweeteners() => _fetchCatalog('api/Sweeteners');
  Future<List<CatalogItem>> getToppings() => _fetchCatalog('api/Toppings');
}
