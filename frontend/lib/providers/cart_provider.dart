import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import '../models/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.fold(0, (sum, item) => sum + item.totalPrice);

  bool isInCart(String mealId) => _items.any((item) => item.meal.id == mealId);

  void addToCart(MealModel meal) {
    final idx = _items.indexWhere((item) => item.meal.id == meal.id);
    if (idx >= 0) {
      _items[idx].quantity++;
    } else {
      _items.add(CartItem(meal: meal));
    }
    notifyListeners();
  }

  void removeFromCart(String mealId) {
    _items.removeWhere((item) => item.meal.id == mealId);
    notifyListeners();
  }

  void increaseQty(String mealId) {
    final idx = _items.indexWhere((item) => item.meal.id == mealId);
    if (idx >= 0) {
      _items[idx].quantity++;
      notifyListeners();
    }
  }

  void decreaseQty(String mealId) {
    final idx = _items.indexWhere((item) => item.meal.id == mealId);
    if (idx >= 0) {
      if (_items[idx].quantity > 1) {
        _items[idx].quantity--;
      } else {
        _items.removeAt(idx);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
