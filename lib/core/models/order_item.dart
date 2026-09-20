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

  final dynamic id;
  final dynamic orderId;
  final dynamic partId;
  final int quantity;
  final double unitPrice;
  final PartRecord? part;

  double get lineTotal => unitPrice * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final partJson = json['parts'];

    return OrderItem(
      id: json['id'],
      orderId: json['order_id'],
      partId: json['part_id'],
      quantity: json['quantity'] as int? ?? 1,
      unitPrice: double.tryParse(json['unit_price'].toString()) ?? 0.0,
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

