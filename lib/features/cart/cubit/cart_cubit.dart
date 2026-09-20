import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/auto_part.dart';
import '../../../core/models/cart_item.dart';
import '../../../core/models/order_record.dart';
import '../../../core/networking/supabase.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());

  bool contains(AutoPart part) =>
      state.items.any((item) => item.part.id == part.id);

  void addPart(AutoPart part, {int quantity = 1}) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((item) => item.part.id == part.id);

    if (index >= 0) {
      items[index] = items[index].copyWith(
        quantity: items[index].quantity + quantity,
      );
    } else {
      items.add(CartItem(part: part, quantity: quantity));
    }

    emit(state.copyWith(items: items));
  }

  void removePart(AutoPart part) {
    final items = state.items.where((item) => item.part.id != part.id).toList();
    emit(state.copyWith(items: items));
  }

  void updateQuantity(AutoPart part, int quantity) {
    if (quantity <= 0) {
      removePart(part);
      return;
    }

    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((item) => item.part.id == part.id);
    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: quantity);
      emit(state.copyWith(items: items));
    }
  }

  void clear() {
    emit(const CartState());
  }

  String buildWhatsAppMessage() {
    final buffer = StringBuffer('Auto Gear Order Request:\n\n');
    for (var i = 0; i < state.items.length; i++) {
      final item = state.items[i];
      buffer.writeln('${i + 1}. Part Name: ${item.part.name}');
      buffer.writeln('   SN Number: ${item.part.sku}');
      if (item.part.oemNumber.isNotEmpty) {
        buffer.writeln('   OEM: ${item.part.oemNumber}');
      }
      buffer.writeln('   Quantity: ${item.quantity}');
      buffer.writeln();
    }
    return buffer.toString().trim();
  }

  CreateOrderRequest toOrderRequest() {
    return CreateOrderRequest(
      status: 'pending',
      whatsappMessage: buildWhatsAppMessage(),
      items: state.items
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
    if (state.isEmpty) {
      throw SupabaseServiceException('Your cart is empty.');
    }

    final order = await SupabaseService.instance.createOrder(toOrderRequest());
    clear();
    return order;
  }
}
