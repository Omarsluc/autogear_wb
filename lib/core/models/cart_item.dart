import 'auto_part.dart';

class CartItem {
  const CartItem({
    required this.part,
    this.quantity = 1,
  });

  final AutoPart part;
  final int quantity;

  int get partId => int.tryParse(part.id) ?? 0;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      part: part,
      quantity: quantity ?? this.quantity,
    );
  }
}
