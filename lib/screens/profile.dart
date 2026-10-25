import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/validation.dart';
import '../data/catalog.dart';
import '../state/shop_state.dart';
import '../widgets/form_fields.dart';
import '../widgets/shop_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.initialTab = 0});
  final int initialTab;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late int tab = widget.initialTab;
  @override
  Widget build(BuildContext context) {
    final state = ShopScope.of(context);
    return PageFrame(
      title: 'Profile',
      largeTitle: true,
      tab: 3,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        children: [
          SurfaceCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 38,
                      backgroundImage: AssetImage('assets/images/avatar.jpg'),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(state.phone),
                          const SizedBox(height: 4),
                          Text(state.email, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      state.signedIn ? 'Verified' : 'Demo profile',
                      style: TextStyle(
                        fontSize: 12,
                        color: state.signedIn
                            ? FurniteTheme.green
                            : FurniteTheme.muted,
                      ),
                    ),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: () => go(context, '/profile/edit'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: FurniteTheme.orange),
                        foregroundColor: FurniteTheme.orange,
                        minimumSize: const Size(58, 28),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text('Edit', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final (i, label) in [
                  'Ongoing',
                  'History',
                  'Voucher',
                  'Card Management',
                ].indexed)
                  Padding(
                    padding: const EdgeInsets.only(right: 18),
                    child: TextButton(
                      onPressed: () => setState(() => tab = i),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: tab == i
                              ? FurniteTheme.ink
                              : const Color(0xFFBDBDBC),
                          fontSize: 15,
                          fontWeight: tab == i
                              ? FontWeight.w700
                              : FontWeight.w400,
                          decoration: tab == i
                              ? TextDecoration.underline
                              : null,
                          decorationColor: FurniteTheme.yellow,
                          decorationThickness: 3,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (tab == 0) ...[
            for (final order in state.orders)
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: SurfaceCard(
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(top: 12),
                    shape: const Border(),
                    leading: Image.asset(
                      order.lines.first.product.asset,
                      width: 48,
                      height: 48,
                    ),
                    title: Text(
                      order.id,
                      style: const TextStyle(
                        color: FurniteTheme.ink,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      '${order.lines.fold<int>(0, (n, e) => n + e.quantity)} items · ${money(order.total)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Text(
                      'Preparing',
                      style: TextStyle(color: FurniteTheme.orange),
                    ),
                    children: [
                      for (final line in order.lines)
                        ListTile(
                          dense: true,
                          title: Text(line.product.name),
                          subtitle: Text('${line.color} · x${line.quantity}'),
                          trailing: Text(money(line.total)),
                        ),
                      const OrderTimeline(stage: 1),
                      Text(
                        'Ordered ${order.date.substring(0, 10)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            const SamplePackage(
              name: 'Package 4',
              items: 3,
              status: 'Preparing',
              image: 'order_one',
            ),
            const SizedBox(height: 18),
            const SamplePackage(
              name: 'Package 3',
              items: 7,
              status: 'Shipping',
              image: 'order_two',
              expanded: true,
            ),
          ],
          if (tab == 1)
            const SizedBox(
              height: 360,
              child: EmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'Your story starts here',
                message: 'Completed orders will appear in your history.',
              ),
            ),
          if (tab == 2)
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'A little welcome home',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const Text(
                        '10%',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: FurniteTheme.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('10% off your items · Demo voucher'),
                  const Divider(),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'FURNITE10',
                          style: TextStyle(
                            color: FurniteTheme.ink,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          state.applyPromo('FURNITE10');
                          toast(
                            context,
                            'Voucher applied to your next checkout',
                          );
                        },
                        child: const Text('Use voucher'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          if (tab == 3) ...[
            if (state.cardLast4 != null) ...[
              CreditCardPreview(last4: state.cardLast4!, holder: state.name),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    final remove = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete saved card?'),
                        content: const Text(
                          'You can add it again at any time.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (remove == true) {
                      state.deleteCard();
                    }
                  },
                  child: const Text('Delete'),
                ),
              ),
            ],
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => go(context, '/card/add'),
              icon: const Icon(Icons.add),
              label: const Text('Add new credit card'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Only the last four digits are saved on this device.',
              style: TextStyle(fontSize: 12),
            ),
          ],
          const SizedBox(height: 28),
          if (!state.signedIn)
            PrimaryButton('Sign in', onPressed: () => go(context, '/signin'))
          else
            TextButton(
              onPressed: () {
                state.signOut();
                toast(context, 'Signed out');
              },
              child: const Text('Sign out'),
            ),
        ],
      ),
    );
  }
}

class SamplePackage extends StatelessWidget {
  const SamplePackage({
    super.key,
    required this.name,
    required this.items,
    required this.status,
    required this.image,
    this.expanded = false,
  });
  final String name, status, image;
  final int items;
  final bool expanded;
  @override
  Widget build(BuildContext context) => SurfaceCard(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    child: ExpansionTile(
      initiallyExpanded: expanded,
      tilePadding: EdgeInsets.zero,
      shape: const Border(),
      collapsedShape: const Border(),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          'assets/images/$image.jpg',
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(name, style: const TextStyle(fontSize: 14)),
      subtitle: Text(
        '$items items · Sample',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Text(
        status,
        style: const TextStyle(color: FurniteTheme.orange),
      ),
      children: [
        const Divider(),
        OrderTimeline(stage: status == 'Shipping' ? 2 : 1),
      ],
    ),
  );
}

class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, this.stage = 2});
  final int stage;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      children: [
        for (final (i, label) in [
          'Receive Order',
          'Preparing',
          'Shipping',
          'Receive',
        ].indexed)
          Row(
            children: [
              SizedBox(
                width: 22,
                height: 34,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (i < 3)
                      Positioned(
                        top: 17,
                        bottom: 0,
                        child: Container(
                          width: 1,
                          color: const Color(0xFF6AD399),
                        ),
                      ),
                    if (i > 0)
                      Positioned(
                        top: 0,
                        bottom: 17,
                        child: Container(
                          width: 1,
                          color: const Color(0xFF6AD399),
                        ),
                      ),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: i <= stage
                            ? const Color(0xFF6AD399)
                            : Colors.white,
                        border: Border.all(color: const Color(0xFF6AD399)),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: i == stage
                      ? FurniteTheme.ink
                      : const Color(0xFFBDBDBC),
                ),
              ),
              const Spacer(),
              if (i <= stage)
                const Text('Demo status', style: TextStyle(fontSize: 12)),
            ],
          ),
      ],
    ),
  );
}

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});
  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final formKey = GlobalKey<FormState>();
  String name = '', email = '', phone = '', street = '', city = '';
  @override
  Widget build(BuildContext context) {
    final state = ShopScope.of(context);
    return PageFrame(
      title: 'Profile & Address',
      cart: false,
      bottom: BottomAction(
        'Save',
        onPressed: () {
          if (!formKey.currentState!.validate()) {
            return;
          }
          formKey.currentState!.save();
          state.updateProfile(
            fullName: name,
            contactEmail: email,
            contactPhone: phone,
            street: street,
            location: city,
          );
          back(context);
          toast(context, 'Profile and address saved');
        },
      ),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 48,
              backgroundImage: AssetImage('assets/images/avatar.jpg'),
            ),
          ),
          const SizedBox(height: 28),
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeading('User Information'),
                const SizedBox(height: 12),
                ShopField(
                  'Full Name',
                  initialValue: state.name,
                  onSaved: (v) => name = v!,
                ),
                ShopField(
                  'Email',
                  initialValue: state.email,
                  keyboard: TextInputType.emailAddress,
                  validator: Validate.email,
                  onSaved: (v) => email = v!,
                ),
                ShopField(
                  'Phone',
                  initialValue: state.phone,
                  keyboard: TextInputType.phone,
                  validator: Validate.phone,
                  onSaved: (v) => phone = v!,
                ),
                const SizedBox(height: 18),
                const SectionHeading('Address'),
                const SizedBox(height: 12),
                ShopField(
                  'Street / House / Apartment',
                  initialValue: state.address,
                  onSaved: (v) => street = v!,
                ),
                ShopField(
                  'City / District',
                  initialValue: state.city,
                  onSaved: (v) => city = v!,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CreditCardPreview extends StatelessWidget {
  const CreditCardPreview({
    super.key,
    required this.last4,
    required this.holder,
  });
  final String last4, holder;
  @override
  Widget build(BuildContext context) => Container(
    height: 190,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      gradient: const LinearGradient(
        colors: [Color(0xFF454960), Color(0xFF272A3B)],
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.credit_card, color: FurniteTheme.yellow, size: 32),
            Spacer(),
            Text(
              'VISA',
              style: TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
          ],
        ),
        const Spacer(),
        Text(
          '••••   ••••   ••••   $last4',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'CARDHOLDER NAME',
          style: TextStyle(color: Colors.white60, fontSize: 9),
        ),
        const SizedBox(height: 4),
        Text(holder, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ],
    ),
  );
}

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});
  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final key = GlobalKey<FormState>();
  String last4 = '';
  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Add Credit Card',
    cart: false,
    bottom: BottomAction(
      'Save Card',
      onPressed: () {
        if (key.currentState!.validate()) {
          key.currentState!.save();
          ShopScope.of(context).saveCard(last4);
          back(context);
          toast(context, 'Card ending $last4 saved');
        }
      },
    ),
    child: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        CreditCardPreview(last4: '••••', holder: ShopScope.of(context).name),
        const SizedBox(height: 28),
        CardForm(formKey: key, onValid: (value) => last4 = value),
        const SizedBox(height: 18),
        const Text(
          'Demo card · only the last four digits are saved.\nTest: 4242 4242 4242 4242 · 12/30 · 123',
          style: TextStyle(fontSize: 12),
        ),
      ],
    ),
  );
}
