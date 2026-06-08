// ignore_for_file: prefer_final_fields

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/meal_model.dart';
import '../constants/api_constants.dart';

class MealProvider extends ChangeNotifier {
  List<MealModel> _meals = [];
  List<MealModel> _favorites = [];
  bool _loading = false;
  String? _error;
  String _selectedCategory = 'All';

  List<MealModel> get meals => _meals;
  List<MealModel> get favorites => _favorites;
  bool get loading => _loading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;

  List<String> _dbCategories = [];
  List<String> get dbCategories => _dbCategories.isEmpty
      ? _meals.map((m) => m.category).toSet().toList()
      : _dbCategories;

  List<String> get categories {
    final list = List<String>.from(dbCategories);
    if (!list.contains('All')) {
      list.insert(0, 'All');
    }
    return list;
  }

  List<MealModel> get filteredMeals {
    if (_selectedCategory == 'All') return _meals;
    return _meals.where((m) => m.category == _selectedCategory).toList();
  }

  bool isFavorite(String mealId) => _favorites.any((m) => m.id == mealId);

  void toggleFavorite(MealModel meal) {
    if (isFavorite(meal.id)) {
      _favorites.removeWhere((m) => m.id == meal.id);
    } else {
      _favorites.add(meal);
    }
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> fetchMeals({String? search}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      String url = '$baseUrl/api/meals';
      if (search != null && search.isNotEmpty) {
        url += '?search=$search';
      }
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        _meals = data.map((m) => MealModel.fromJson(m)).toList();
      } else {
        _error = 'Failed to load meals';
      }
    } catch (e) {
      _error = 'Connection error';
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> deleteMeal(String mealId, String token) async {
    try {
      final res = await http.delete(
        Uri.parse('$baseUrl/api/meals/$mealId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        _meals.removeWhere((m) => m.id == mealId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> fetchCategories() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/categories'));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        _dbCategories = data.map((c) => c['name'] as String).toList();
        notifyListeners();
      }
    } catch (e) {
      // fallback
    }
  }

  Future<bool> addCategory(String name, String token) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/categories'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': name}),
      );
      if (res.statusCode == 201) {
        await fetchCategories();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
