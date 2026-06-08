class OrderModel {
  final String id;
  final List<OrderItem> orderItems;
  final double totalPrice;
  final bool isPaid;
  final bool isDelivered;
  final String createdAt;
  final String phoneNumber;
  final String location;
  final String userName;
  final String userEmail;

  OrderModel({
    required this.id,
    required this.orderItems,
    required this.totalPrice,
    required this.isPaid,
    required this.isDelivered,
    required this.createdAt,
    required this.phoneNumber,
    required this.location,
    required this.userName,
    required this.userEmail,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'];
    String uName = '';
    String uEmail = '';
    if (userData != null && userData is Map<String, dynamic>) {
      uName = userData['name'] ?? '';
      uEmail = userData['email'] ?? '';
    }

    return OrderModel(
      id: json['_id'] ?? '',
      orderItems: (json['orderItems'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      isPaid: json['isPaid'] ?? false,
      isDelivered: json['isDelivered'] ?? false,
      createdAt: json['createdAt'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      location: json['location'] ?? '',
      userName: uName,
      userEmail: uEmail,
    );
  }

  String get status {
    if (isDelivered) return 'Delivered';
    if (isPaid) return 'On the way';
    return 'Pending Payment';
  }
}

class OrderItem {
  final String name;
  final int qty;
  final String image;
  final double price;
  final String mealId;

  OrderItem({
    required this.name,
    required this.qty,
    required this.image,
    required this.price,
    required this.mealId,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name'] ?? '',
      qty: json['qty'] ?? 1,
      image: json['image'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      mealId: json['meal'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'qty': qty,
        'image': image,
        'price': price,
        'meal': mealId,
      };
}
