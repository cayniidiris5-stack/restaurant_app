import '../constants/api_constants.dart';

class MealModel {
  final String id;
  final String name;
  final String image;
  final String description;
  final double price;
  final String category;
 
  MealModel({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.price,
    required this.category,
  });

  String get fullImageUrl {
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return image;
    }
    return '$baseUrl$image';
  }

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'] ?? 'General',
    );
  }
}
