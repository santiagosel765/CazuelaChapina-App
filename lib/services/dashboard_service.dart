import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/dashboard_summary.dart';
import 'auth_service.dart';

class DashboardService {
  static const String _baseUrl = 'http://10.0.2.2:5151';
  final AuthService _authService = AuthService();

  Future<DashboardSummary?> fetchSummary({
    required DateTime startDate,
    required DateTime endDate,
    int branchId = 1,
  }) async {
    final token = await _authService.getToken();
    if (token == null) return null;

    final uri = Uri.parse('$_baseUrl/api/Dashboard/summary').replace(
      queryParameters: {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'branchId': branchId.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return DashboardSummary.fromJson(data);
    }
    return null;
  }
}
