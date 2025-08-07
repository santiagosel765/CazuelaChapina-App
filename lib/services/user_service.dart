import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user.dart';
import '../models/role.dart';
import '../models/module.dart';
import '../models/permission.dart';
import 'auth_service.dart';

class UserService {
  static const String _baseUrl = 'http://10.0.2.2:5151';
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<List<User>> fetchUsers() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/Users'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => User.fromJson(e)).toList();
    }
    throw Exception('Error al obtener usuarios');
  }

  Future<List<Role>> fetchRoles() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/Roles'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Role.fromJson(e)).toList();
    }
    throw Exception('Error al obtener roles');
  }

  Future<List<Module>> fetchModules() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/Modules'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Module.fromJson(e)).toList();
    }
    throw Exception('Error al obtener módulos');
  }

  Future<List<Permission>> fetchPermissionsByRole(int roleId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/Roles/$roleId/permissions'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Permission.fromJson(e)).toList();
    }
    throw Exception('Error al obtener permisos');
  }

  Future<bool> createUser({
    required String fullName,
    required String username,
    required String password,
    required String email,
    required String phone,
    required String status,
    required int roleId,
  }) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('$_baseUrl/api/Auth/register'),
      headers: headers,
      body: jsonEncode({
        'fullName': fullName,
        'username': username,
        'password': password,
        'email': email,
        'phone': phone,
        'status': status,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final data = jsonDecode(response.body);
        final int userId = data['id'] ?? 0;
        await assignRole(userId, roleId);
      } catch (_) {}
      return true;
    }
    return false;
  }

  Future<bool> updateUser(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/Users/$id'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  Future<bool> changePassword(int id, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/Users/$id/password'),
      headers: await _headers(),
      body: jsonEncode({'password': password}),
    );
    return response.statusCode == 200;
  }

  Future<bool> assignRole(int userId, int roleId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/Users/$userId/roles'),
      headers: await _headers(),
      body: jsonEncode({'roleId': roleId}),
    );
    return response.statusCode == 200;
  }

  Future<bool> updatePermissions(int roleId, List<Permission> permissions) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/Roles/$roleId/permissions'),
      headers: await _headers(),
      body: jsonEncode(permissions.map((e) => e.toJson()).toList()),
    );
    return response.statusCode == 200;
  }
}
