import '../constants/api_constants.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final bool isAdmin;
  final bool isRestaurant;
  final String image;
  final String token;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.isAdmin,
    required this.isRestaurant,
    required this.image,
    required this.token,
  });

  String get fullImageUrl {
    if (image.isEmpty) return '';
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return image;
    }
    return '$baseUrl$image';
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
      isRestaurant: json['isRestaurant'] ?? false,
      image: json['image'] ?? '',
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'isAdmin': isAdmin,
      'isRestaurant': isRestaurant,
      'image': image,
      'token': token,
    };
  }
}
