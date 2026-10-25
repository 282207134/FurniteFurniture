import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../data/catalog.dart';
import '../state/shop_state.dart';
import '../widgets/shop_widgets.dart';
import 'product.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = ShopScope.of(context);
    return PageFrame(
      title: '',
      cart: false,
      bottom: state.cart.isEmpty
          ? null
          : BottomAction('Checkout', onPressed: () => go(context, '/checkout')),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: UnderlinedTitle('Your Cart'),
          ),
          Expanded(
            child: state.cart.isEmpty
                ? EmptyState(
                    icon: Icons.shopping_cart_outlined,
                    title: 'Your cart is empty',
                    message: 'A beautiful home starts with one little thing.',
                    action: 'Explore the collection',
                    onAction: () => go(context, '/products'),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(0, 0, 24, 24),
                    itemCount: state.cart.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final line = state.cart[index];
                      final p = line.product;
                      return SizedBox(
                        height: 142,
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () => go(context, '/product/${p.id}'),
                              child: SizedBox(
                                width: 128,
                                height: 132,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 0,
                                      right: 8,
                                      bottom: 10,
                                      height: 56,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: p.background,
                                          borderRadius:
                                              const BorderRadius.horizontal(
                                                right: Radius.circular(35),
                                              ),
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Image.asset(
                                          p.asset,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: const TextStyle(
                                      color: FurniteTheme.ink,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    money(line.total),
                                    style: const TextStyle(
                                      color: FurniteTheme.ink,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    line.color,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  TextButton(
                                    onPressed: () => _customize(context, line),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(40, 28),
                                    ),
                                    child: const Text(
                                      'Customize',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  tooltip: 'Remove ${p.name}',
                                  onPressed: () => _remove(context, line),
                                  icon: const Icon(
                                    Icons.close,
                                    size: 17,
                                    color: FurniteTheme.muted,
                                  ),
                                ),
                                CircleAvatar(
                                  radius: 17,
                                  backgroundColor: FurniteTheme.yellow,
                                  child: Text(
                                    'x${line.quantity}',
                                    style: const TextStyle(
                                      color: FurniteTheme.ink,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          if (state.cart.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(60, 12, 24, 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.local_shipping_outlined, size: 24),
                        const SizedBox(height: 2),
                        Text(
                          money(state.shipping),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            color: FurniteTheme.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFBDBDBC),
                          ),
                        ),
                        Text(
                          money(state.total),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Text(
                          'Shipping included',
                          style: TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _remove(BuildContext context, CartLine line) async {
    final state = ShopScope.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove this item?'),
        content: Text(line.product.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      state.setQuantity(line, 0);
    }
  }

  void _customize(BuildContext context, CartLine line) {
    final state = ShopScope.of(context);
    int quantity = line.quantity;
    String color = line.color;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheet) => StatefulBuilder(
        builder: (sheet, update) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  line.product.asset,
                  height: 200,
                  width: double.infinity,
                ),
                const SizedBox(height: 16),
                Text(
                  line.product.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 18),
                ColorPicker(
                  primaryColor: line.product.color,
                  value: color,
                  onChanged: (value) => update(() => color = value),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(child: Text('Quantity')),
                    QuantityControl(
                      value: quantity,
                      onChanged: (value) => update(() => quantity = value),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  'Save',
                  onPressed: () {
                    state.customize(line, color: color, quantity: quantity);
                    Navigator.pop(sheet);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
