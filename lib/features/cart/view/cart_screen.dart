import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/cart_item.dart';
import '../../../core/networking/supabase.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../../auth/view/auth_screen.dart';
import '../../orders/view/orders_screen.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isCheckingOut = false;

  Future<void> _sendToWhatsApp(String message) async {
    const phoneNumber = '201122291859';
    final whatsappUrl = Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
    );
    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(whatsappUrl);
      }
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
    }
  }

  Future<void> _checkout() async {
    final authState = context.read<AuthCubit>().state;
    final cartCubit = context.read<CartCubit>();

    if (cartCubit.state.isEmpty) return;

    if (!authState.isAuthenticated) {
      final signedIn = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => const AuthScreen(checkoutFlow: true),
        ),
      );

      if (!mounted || signedIn != true) return;
    }

    final currentAuthState = context.read<AuthCubit>().state;
    final userName = currentAuthState.userName ?? currentAuthState.displayName;
    final userPhone = currentAuthState.userPhone;

    setState(() => _isCheckingOut = true);

    try {
      final whatsappMessage = cartCubit.buildWhatsAppMessage(
        userName: userName,
        userPhone: userPhone,
      );
      
      // Automatically send cart content, user name and phone to WhatsApp (+201122291859)
      await _sendToWhatsApp(whatsappMessage);

      final order = await cartCubit.checkout(
        userName: userName,
        userPhone: userPhone,
      );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
          title: const Text('Order submitted'),
          content: Text(
            'Your quote request #${order.id} was sent successfully. '
            'WhatsApp was launched with your order items (Quantity & SN numbers) to +201122291859.',
          ),
          actions: [
            TextButton.icon(
              onPressed: () => _sendToWhatsApp(order.whatsappMessage ?? whatsappMessage),
              icon: const Icon(Icons.chat),
              label: const Text('WhatsApp'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const OrdersScreen()),
                );
              },
              child: const Text('View Orders'),
            ),
          ],
        ),
      );
    } on SupabaseServiceException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during checkout: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isCheckingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cartState) {
        return BlocBuilder<AuthCubit, AppAuthState>(
          builder: (context, authState) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Cart'),
                actions: [
                  if (!cartState.isEmpty)
                    TextButton(
                      onPressed: () => context.read<CartCubit>().clear(),
                      child: const Text('Clear', style: TextStyle(color: Colors.white)),
                    ),
                ],
              ),
              body: cartState.isEmpty
                  ? _EmptyCart(onBrowse: () => Navigator.pop(context))
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: cartState.items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              return _CartItemTile(item: cartState.items[index]);
                            },
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(top: BorderSide(color: AppColors.border)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${cartState.itemCount} item${cartState.itemCount == 1 ? '' : 's'}',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const Text(
                                    'Quote on request',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              if (!authState.isAuthenticated) ...[
                                const SizedBox(height: 8),
                                const Text(
                                  'You will be asked to sign in before submitting your order.',
                                ),
                              ] else ...[
                                const SizedBox(height: 8),
                                Text('Signed in as ${authState.displayName}'),
                              ],
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _isCheckingOut ? null : _checkout,
                                icon: _isCheckingOut
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.send_outlined),
                                label: Text(_isCheckingOut ? 'Submitting...' : 'Checkout'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            );
          },
        );
      },
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 72,
              color: AppColors.primary.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 16),
            Text('Your cart is empty', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Add parts from the catalog to request a quote.'),
            const SizedBox(height: 24),
            OutlinedButton(onPressed: onBrowse, child: const Text('Browse catalog')),
          ],
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final cartCubit = context.read<CartCubit>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.part.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('SKU: ${item.part.sku}  •  OEM: ${item.part.oemNumber}'),
            Text('${item.part.make} ${item.part.model}'),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton.outlined(
                  onPressed: item.quantity > 1
                      ? () => cartCubit.updateQuantity(item.part, item.quantity - 1)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '${item.quantity}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton.outlined(
                  onPressed: () => cartCubit.updateQuantity(item.part, item.quantity + 1),
                  icon: const Icon(Icons.add),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Remove',
                  onPressed: () => cartCubit.removePart(item.part),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
