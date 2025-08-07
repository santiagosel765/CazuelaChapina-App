import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../models/sale.dart';
import 'auth_service.dart';

class SalesService {
  static const String _baseUrl = 'http://10.0.2.2:5151';
  static const String _offlineBox = 'offline_sales';

  final AuthService _authService = AuthService();

  Future<Box> _openBox() async {
    if (!Hive.isBoxOpen(_offlineBox)) {
      return await Hive.openBox(_offlineBox);
    }
    return Hive.box(_offlineBox);
  }

  Future<bool> registerSale(Sale sale) async {
    final token = await _authService.getToken();
    if (token == null) {
      await saveSaleOffline(sale);
      return false;
    }
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/Sales'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(sale.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } catch (_) {}
    await saveSaleOffline(sale);
    return false;
  }

  Future<void> saveSaleOffline(Sale sale) async {
    final box = await _openBox();
    await box.add(sale.toLocalJson());
  }

  Future<List<Sale>> getPendingSales() async {
    final box = await _openBox();
    return box.values
        .map((e) => Sale.fromLocalJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> syncPendingSales() async {
    final token = await _authService.getToken();
    if (token == null) return;
    final box = await _openBox();
    final pending = box.toMap();
    for (final entry in pending.entries) {
      final sale =
          Sale.fromLocalJson(Map<String, dynamic>.from(entry.value));
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/api/Sync/sale'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(sale.toJson()),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          await box.delete(entry.key);
        }
      } catch (_) {}
    }
  }

  Future<List<Sale>> fetchSales() async {
    final token = await _authService.getToken();
    if (token == null) return [];
    final response = await http.get(
      Uri.parse('$_baseUrl/api/Sales'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Sale.fromJson(e)).toList();
    }
    return [];
  }
}

