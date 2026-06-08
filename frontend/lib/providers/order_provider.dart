import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../constants/api_constants.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderModel> _myOrders = [];
  List<OrderModel> _allOrders = [];
  Map<String, dynamic> _analytics = {};
  bool _loading = false;
  String? _error;

  List<OrderModel> get myOrders => _myOrders;
  List<OrderModel> get allOrders => _allOrders;
  Map<String, dynamic> get analytics => _analytics;
  bool get loading => _loading;
  String? get error => _error;

  Future<bool> placeOrder(List<CartItem> items, double total, String token, String phoneNumber, String location) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final orderItems = items
          .map((item) => {
                'name': item.meal.name,
                'qty': item.quantity,
                'image': item.meal.image,
                'price': item.meal.price,
                'meal': item.meal.id,
              })
          .toList();

      final res = await http.post(
        Uri.parse('$baseUrl/api/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'orderItems': orderItems,
          'totalPrice': total,
          'phoneNumber': phoneNumber,
          'location': location,
        }),
      );
      if (res.statusCode == 201) {
        _loading = false;
        notifyListeners();
        return true;
      } else {
        _error = jsonDecode(res.body)['message'] ?? 'Order failed';
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Connection error';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchMyOrders(String token) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/orders/myorders'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        _myOrders = data.map((o) => OrderModel.fromJson(o)).toList();
      } else {
        _error = 'Failed to load orders';
      }
    } catch (e) {
      _error = 'Connection error';
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> fetchAllOrders(String token) async {
    _loading = true;
    notifyListeners();
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/orders'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        _allOrders = data.map((o) => OrderModel.fromJson(o)).toList();
      }
    } catch (e) {
      _error = 'Connection error';
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> fetchAnalytics(String token) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/orders/analytics'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        _analytics = jsonDecode(res.body);
        notifyListeners();
      }
    } catch (e) {
      // silent
    }
  }

  Future<bool> markAsDelivered(String orderId, String token) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/api/orders/$orderId/deliver'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        await fetchAllOrders(token);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> markAsPaid(String orderId, String token) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/api/orders/$orderId/pay'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        await fetchMyOrders(token);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
