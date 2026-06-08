import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../constants/api_constants.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _loading = false;
  String? _error;
  bool _initialized = false;

  UserModel? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isRestaurant => _user?.isRestaurant ?? false;
  String get token => _user?.token ?? '';
  bool get initialized => _initialized;

  AuthProvider() {
    _loadUserFromPrefs();
  }

  Future<void> _loadUserFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('user');
      if (userStr != null) {
        _user = UserModel.fromJson(jsonDecode(userStr));
      }
    } catch (e) {
      _error = 'Failed to load local session';
    }
    _initialized = true;
    notifyListeners();
  }

  Future<bool> register(String name, String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 201) {
        _user = UserModel.fromJson(data);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(data));
        _loading = false;
        notifyListeners();
        return true;
      } else {
        _error = data['message'] ?? 'Registration failed';
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Connection error. Please check your network.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        _user = UserModel.fromJson(data);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(data));
        _loading = false;
        notifyListeners();
        return true;
      } else {
        _error = data['message'] ?? 'Login failed';
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Connection error. Please check your network.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    notifyListeners();
  }

  // ─── Admin User/Restaurant Management ─────────────────────────────────────
  List<UserModel> _allUsers = [];
  List<UserModel> get allUsers => _allUsers;

  Future<bool> fetchAllUsers(String adminToken) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $adminToken',
        },
      );
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        _allUsers = data.map((json) => UserModel.fromJson(json)).toList();
        _loading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(res.body);
        _error = data['message'] ?? 'Failed to fetch users';
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Connection error. Please check your network.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createUserByAdmin(
    String adminToken,
    String name,
    String email,
    String password,
    bool isRestaurant,
  ) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $adminToken',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'isRestaurant': isRestaurant,
        }),
      );
      if (res.statusCode == 201) {
        await fetchAllUsers(adminToken);
        return true;
      } else {
        final data = jsonDecode(res.body);
        _error = data['message'] ?? 'Failed to create user/restaurant';
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Connection error. Please check your network.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUserByAdmin(
    String adminToken,
    String userId, {
    String? name,
    String? email,
    String? password,
    bool? isRestaurant,
    bool? isAdmin,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (password != null && password.isNotEmpty) body['password'] = password;
      if (isRestaurant != null) body['isRestaurant'] = isRestaurant;
      if (isAdmin != null) body['isAdmin'] = isAdmin;

      final res = await http.put(
        Uri.parse('$baseUrl/api/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $adminToken',
        },
        body: jsonEncode(body),
      );
      if (res.statusCode == 200) {
        await fetchAllUsers(adminToken);
        return true;
      } else {
        final data = jsonDecode(res.body);
        _error = data['message'] ?? 'Failed to update user/restaurant';
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Connection error. Please check your network.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUserByAdmin(String adminToken, String userId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await http.delete(
        Uri.parse('$baseUrl/api/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $adminToken',
        },
      );
      if (res.statusCode == 200) {
        await fetchAllUsers(adminToken);
        return true;
      } else {
        final data = jsonDecode(res.body);
        _error = data['message'] ?? 'Failed to delete user';
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Connection error. Please check your network.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfileImage(Uint8List imageBytes, String filename) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/api/users/profile'))
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: filename,
        ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _user = UserModel.fromJson(data);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(data));
        _loading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Failed to update profile image';
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Connection error. Please check your network.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }
}
