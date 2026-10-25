import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/validation.dart';
import '../data/catalog.dart';
import '../state/shop_state.dart';
import '../widgets/form_fields.dart';
import '../widgets/shop_widgets.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int step = 0;
  String method = 'Credit Card';
  String name = '', phone = '', street = '', city = '', last4 = '';
  final infoKey = GlobalKey<FormState>(), cardKey = GlobalKey<FormState>();
  bool initialized = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      final state = ShopScope.of(context);
      name = state.name;
      phone = state.phone;
      street = state.address;
      city = state.city;
      last4 = state.cardLast4 ?? '';
      initialized = true;
    }
  }

  void _next() {
    final state = ShopScope.of(context);
    if (step == 0) {
      if (!infoKey.currentState!.validate()) {
        return;
      }
      infoKey.currentState!.save();
      state.updateProfile(
        fullName: name,
        contactEmail: state.email,
        contactPhone: phone,
        street: street,
        location: city,
      );
    }
    if (step == 1 && method == 'Credit Card' && state.cardLast4 == null) {
      if (!cardKey.currentState!.validate()) {
        return;
      }
      cardKey.currentState!.save();
    }
    if (step < 2) {
      setState(() => step++);
      return;
    }
    final order = state.placeOrder();
    if (order != null) {
      Navigator.pushReplacementNamed(context, '/success', arguments: order);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ShopScope.of(context);
    return PageFrame(
      title: 'Checkout',
      cart: false,
      bottom: state.cart.isEmpty
          ? null
          : BottomAction(
              step == 2 ? 'Place Order' : 'Continue',
              onPressed: _next,
            ),
      child: state.cart.isEmpty
          ? EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Nothing to check out',
              message: 'Add a piece you love to get started.',
              action: 'Explore',
              onAction: () => go(context, '/products'),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                  child: Row(
                    children: [
                      for (int i = 0; i < 3; i++)
                        Expanded(
                          child: InkWell(
                            onTap: i < step
                                ? () => setState(() => step = i)
                                : null,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 2,
                                        color: i == 0
                                            ? Colors.transparent
                                            : i <= step
                                            ? FurniteTheme.green
                                            : FurniteTheme.line,
                                      ),
                                    ),
                                    Container(
                                      width: 13,
                                      height: 13,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: i <= step
                                            ? FurniteTheme.green
                                            : Colors.white,
                                        border: Border.all(
                                          color: FurniteTheme.green,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 2,
                                        color: i == 2
                                            ? Colors.transparent
                                            : i < step
                                            ? FurniteTheme.green
                                            : FurniteTheme.line,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  [
                                    'PERSONAL INFO',
                                    'PAYMENT',
                                    'CONFIRMATION',
                                  ][i],
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: step == i
                                        ? FurniteTheme.ink
                                        : const Color(0xFFBDBDBC),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    key: ValueKey(step),
                    padding: const EdgeInsets.all(24),
                    children: [
                      if (step == 0)
                        Form(
                          key: infoKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionHeading('Deliver To'),
                              const SizedBox(height: 16),
                              ShopField(
                                'Full Name',
                                initialValue: name,
                                onSaved: (value) => name = value!,
                              ),
                              ShopField(
                                'Phone Number',
                                initialValue: phone,
                                keyboard: TextInputType.phone,
                                validator: Validate.phone,
                                onSaved: (value) => phone = value!,
                              ),
                              const SizedBox(height: 14),
                              const SectionHeading('Address'),
                              const SizedBox(height: 12),
                              ShopField(
                                'House / Apartment / Street',
                                initialValue: street,
                                onSaved: (value) => street = value!,
                              ),
                              ShopField(
                                'City / District',
                                initialValue: city,
                                onSaved: (value) => city = value!,
                              ),
                              const ShopField(
                                'Zip / Postal Code',
                                initialValue: 'HR9 6AX',
                              ),
                              const Text(
                                '* Required',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      if (step == 1) ...[
                        const SectionHeading('Payment Method'),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            for (final (label, icon) in [
                              ('Cash', Icons.payments_outlined),
                              ('Credit Card', Icons.credit_card_outlined),
                            ]) ...[
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => method = label),
                                  child: Container(
                                    height: 76,
                                    decoration: BoxDecoration(
                                      color: method == label
                                          ? FurniteTheme.yellow
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: const [FurniteTheme.shadow],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          icon,
                                          size: 32,
                                          color: method == label
                                              ? Colors.white
                                              : const Color(0xFF737D94),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          label,
                                          style: TextStyle(
                                            color: method == label
                                                ? Colors.white
                                                : const Color(0xFF737D94),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              if (label == 'Cash') const SizedBox(width: 16),
                            ],
                          ],
                        ),
                        const SizedBox(height: 32),
                        if (method == 'Credit Card') ...[
                          const SectionHeading('Credit Card Detail'),
                          const SizedBox(height: 24),
                          if (state.cardLast4 != null)
                            SurfaceCard(
                              child: Row(
                                children: [
                                  const Icon(Icons.credit_card),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text('Visa •••• ${state.cardLast4}'),
                                  ),
                                  TextButton(
                                    onPressed: state.deleteCard,
                                    child: const Text('Change'),
                                  ),
                                ],
                              ),
                            )
                          else
                            CardForm(
                              formKey: cardKey,
                              onValid: (value) => last4 = value,
                            ),
                          const SizedBox(height: 16),
                          const Text(
                            'Demo checkout · no payment is charged.\nTest card: 4242 4242 4242 4242 · 12/30 · 123',
                            style: TextStyle(fontSize: 12),
                          ),
                        ] else
                          const SurfaceCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cash on delivery',
                                  style: TextStyle(
                                    color: FurniteTheme.ink,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Pay when your order arrives. This is a demo order; no delivery will be arranged.',
                                ),
                              ],
                            ),
                          ),
                      ],
                      if (step == 2) ...[
                        SectionHeading(
                          'Address',
                          action: 'Change',
                          onAction: () => setState(() => step = 0),
                        ),
                        Text(
                          '$street\n$city',
                          style: const TextStyle(color: Color(0xFF737D94)),
                        ),
                        const Divider(),
                        SectionHeading(
                          'Contact',
                          action: 'Edit',
                          onAction: () => setState(() => step = 0),
                        ),
                        Text(
                          '$name, $phone',
                          style: const TextStyle(color: Color(0xFF737D94)),
                        ),
                        const Divider(),
                        const SectionHeading('Order Summary'),
                        const SizedBox(height: 12),
                        for (final line in state.cart)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Image.asset(
                                  line.product.asset,
                                  width: 40,
                                  height: 48,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        line.product.name,
                                        style: const TextStyle(
                                          color: FurniteTheme.ink,
                                        ),
                                      ),
                                      Text(
                                        line.color,
                                        style: const TextStyle(
                                          color: Color(0xFFBDBDBC),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      money(line.total),
                                      style: const TextStyle(
                                        color: FurniteTheme.ink,
                                      ),
                                    ),
                                    Text(
                                      'Qty: ${line.quantity}',
                                      style: const TextStyle(
                                        color: Color(0xFFBDBDBC),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        const Divider(),
                        SummaryRow('Subtotal', money(state.subtotal)),
                        SummaryRow('Shipping fee', money(state.shipping)),
                        if (state.discount > 0)
                          SummaryRow(
                            'Discount (10%)',
                            '− ${money(state.discount)}',
                          ),
                        SummaryRow(
                          'Method',
                          method == 'Cash'
                              ? 'Cash on delivery'
                              : 'Visa •••• $last4',
                        ),
                        const Divider(),
                        SummaryRow(
                          'Total',
                          money(state.total),
                          emphasized: true,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => showPromoSheet(context),
                            child: Text(
                              state.promo == null
                                  ? '+ Promo code or voucher'
                                  : '${state.promo} applied · Edit',
                            ),
                          ),
                        ),
                        const Text(
                          'Demo order · no payment or delivery is initiated.',
                          style: TextStyle(fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  const SummaryRow(
    this.label,
    this.value, {
    super.key,
    this.emphasized = false,
  });
  final String label, value;
  final bool emphasized;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: emphasized
                ? Theme.of(context).textTheme.titleLarge
                : const TextStyle(color: Color(0xFF737D94)),
          ),
        ),
        Text(
          value,
          style: emphasized
              ? Theme.of(context).textTheme.titleLarge
              : const TextStyle(color: Color(0xFF737D94)),
        ),
      ],
    ),
  );
}

void showPromoSheet(BuildContext context) {
  final state = ShopScope.of(context);
  final formKey = GlobalKey<FormState>();
  String code = '';
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheet) => Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.viewInsetsOf(sheet).bottom + 24,
      ),
      child: SafeArea(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Promo code', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ShopField(
                'Enter promo code',
                initialValue: state.promo,
                onSaved: (value) => code = value!,
                validator: (value) =>
                    [
                      'FURNITE10',
                      'BLFD30',
                    ].contains(value?.trim().toUpperCase())
                    ? null
                    : 'Try FURNITE10 for 10% off',
              ),
              const Text('Use FURNITE10 to save 10% on your items.'),
              const SizedBox(height: 24),
              PrimaryButton(
                'Apply',
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    state.applyPromo(code);
                    Navigator.pop(sheet);
                    toast(context, 'Promo code applied');
                  }
                },
              ),
              if (state.promo != null)
                Center(
                  child: TextButton(
                    onPressed: () {
                      state.removePromo();
                      Navigator.pop(sheet);
                    },
                    child: const Text('Remove promo code'),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class SuccessScreen extends StatelessWidget {
  const SuccessScreen(this.order, {super.key});
  final ShopOrder? order;
  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Order Confirmation',
    cart: false,
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(
              color: Color(0xFFEDFAF1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 66, color: FurniteTheme.green),
          ),
          const SizedBox(height: 32),
          Text(
            order == null ? 'No order yet' : 'Make yourself at home.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            order == null
                ? 'Your next favorite piece is waiting.'
                : 'Your demo order has been placed.\nThank you for shopping with Furnite.',
            textAlign: TextAlign.center,
          ),
          if (order != null) ...[
            const SizedBox(height: 24),
            Text(order!.id, style: const TextStyle(color: FurniteTheme.ink)),
            const SizedBox(height: 8),
            Text(
              money(order!.total),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
          const SizedBox(height: 40),
          PrimaryButton(
            'View My Orders',
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/profile',
              (_) => false,
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
            child: const Text('Continue exploring'),
          ),
        ],
      ),
    ),
  );
}
