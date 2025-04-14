class OrderItem {
  final String productId;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
    );
  }
}

class Order {
  final String id;
  final List<OrderItem> items;
  final double totalPrice;
  final String orderStatus;
  final String paymentStatus;
  final String deliveryAddress;
  final String paymentMethod;
  final DateTime createdAt;
  final DateTime deliveredAt;

  Order({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.orderStatus,
    required this.paymentStatus,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.createdAt,
    required this.deliveredAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'],
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      totalPrice: json['totalPrice'].toDouble(),
      orderStatus: json['orderStatus'],
      paymentStatus: json['paymentStatus'],
      deliveryAddress: json['deliveryAddress'],
      paymentMethod: json['paymentMethod'],
      createdAt: DateTime.parse(json['createdAt']),
      deliveredAt: DateTime.parse(json['deliveredAt']),
    );
  }
}
