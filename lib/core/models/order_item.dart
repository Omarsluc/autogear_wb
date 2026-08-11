import 'part_record.dart';

class OrderItem {
  const OrderItem({
    required this.id,
    required this.orderId,
    required this.partId,
    required this.quantity,
    required this.unitPrice,
    this.part,
  });

  final int id;
  final int orderId;
  final int partId;
  final int quantity;
  final double unitPrice;
  final PartRecord? part;

  double get lineTotal => unitPrice * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final partJson = json['parts'];

    return OrderItem(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      partId: json['part_id'] as int,
      quantity: json['quantity'] as int,
      unitPrice: double.parse(json['unit_price'].toString()),
      part: partJson is Map<String, dynamic>
          ? PartRecord.fromJson(partJson)
          : null,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'part_id': partId,
        'quantity': quantity,
        'unit_price': unitPrice,
      };
}
