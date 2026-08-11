import 'package:flutter/foundation.dart';

import '../../../core/models/auto_part.dart';
import '../../../core/models/cart_item.dart';
import '../../../core/models/order_record.dart';
import '../../../core/networking/supabase.dart';

class CartViewModel extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => _items.isEmpty;

  bool contains(AutoPart part) => _items.any((item) => item.part.id == part.id);

  void addPart(AutoPart part, {int quantity = 1}) {
    final index = _items.indexWhere((item) => item.part.id == part.id);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + quantity,
      );
    } else {
      _items.add(CartItem(part: part, quantity: quantity));
    }
    notifyListeners();
  }

  void removePart(AutoPart part) {
    _items.removeWhere((item) => item.part.id == part.id);
    notifyListeners();
  }

  void updateQuantity(AutoPart part, int quantity) {
    if (quantity <= 0) {
      removePart(part);
      return;
    }

    final index = _items.indexWhere((item) => item.part.id == part.id);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  String buildWhatsAppMessage() {
    final buffer = StringBuffer('Auto Gear order request:\n');
    for (final item in _items) {
      buffer.writeln(
        '- ${item.part.name} (SKU: ${item.part.sku}, OEM: ${item.part.oemNumber}) x${item.quantity}',
      );
    }
    return buffer.toString().trim();
  }

  CreateOrderRequest toOrderRequest() {
    return CreateOrderRequest(
      status: 'pending',
      whatsappMessage: buildWhatsAppMessage(),
      items: _items
          .map(
            (item) => CreateOrderItemRequest(
              partId: item.partId,
              quantity: item.quantity,
              unitPrice: 0,
            ),
          )
          .toList(),
    );
  }

  Future<OrderRecord> checkout() async {
    if (_items.isEmpty) {
      throw SupabaseServiceException('Your cart is empty.');
    }

    final order = await SupabaseService.instance.createOrder(toOrderRequest());
    clear();
    return order;
  }
}
