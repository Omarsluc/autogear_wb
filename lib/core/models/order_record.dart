import 'order_item.dart';

class OrderRecord {
  const OrderRecord({
    required this.id,
    required this.userId,
    required this.status,
    this.whatsappMessage,
    this.totalPrice,
    this.createdAt,
    this.items = const [],
  });

  final int id;
  final String userId;
  final String status;
  final String? whatsappMessage;
  final double? totalPrice;
  final DateTime? createdAt;
  final List<OrderItem> items;

  factory OrderRecord.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['order_items'];

    return OrderRecord(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      status: json['status'] as String,
      whatsappMessage: json['whatsapp_message'] as String?,
      totalPrice: json['total_price'] != null
          ? double.tryParse(json['total_price'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      items: itemsJson is List
          ? itemsJson
              .whereType<Map<String, dynamic>>()
              .map(OrderItem.fromJson)
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'user_id': userId,
        'status': status,
        if (whatsappMessage != null) 'whatsapp_message': whatsappMessage,
        if (totalPrice != null) 'total_price': totalPrice,
      };
}
