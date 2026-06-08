import 'meal_model.dart';

class CartItem {
  final MealModel meal;
  int quantity;

  CartItem({required this.meal, this.quantity = 1});

  double get totalPrice => meal.price * quantity;
}
