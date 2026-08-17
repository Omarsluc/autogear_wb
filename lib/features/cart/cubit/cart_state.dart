import '../../../core/models/cart_item.dart';

class CartState {
  const CartState({this.items = const []});

  final List<CartItem> items;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => items.isEmpty;

  CartState copyWith({List<CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }
}
