import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/branch.dart';
import '../models/branch_report.dart';
import 'auth_service.dart';

class BranchService {
  static const String _baseUrl = 'http://10.0.2.2:5151';
  final AuthService _authService = AuthService();

  Future<List<Branch>> getAllBranches() async {
    final token = await _authService.getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/api/Branches'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Branch.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> createBranch(Branch branch) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$_baseUrl/api/Branches'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(branch.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<BranchReport?> getBranchReport(int branchId) async {
    final token = await _authService.getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$_baseUrl/api/Branches/$branchId/report'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return BranchReport.fromJson(data);
    }
    return null;
  }
}
