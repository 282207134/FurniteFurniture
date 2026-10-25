import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../data/catalog.dart';
import '../state/shop_state.dart';

void go(BuildContext context, String route) =>
    Navigator.of(context).pushNamed(route);
void back(BuildContext context) {
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  } else {
    Navigator.pushReplacementNamed(context, '/');
  }
}

void toast(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));

class PageFrame extends StatelessWidget {
  const PageFrame({
    super.key,
    required this.title,
    required this.child,
    this.largeTitle = false,
    this.tab,
    this.bottom,
    this.cart = true,
    this.background = Colors.white,
    this.actions,
  });
  final String title;
  final Widget child;
  final bool largeTitle, cart;
  final int? tab;
  final Widget? bottom, actions;
  final Color background;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: background,
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          SizedBox(
            height: largeTitle ? 96 : 76,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Row(
                children: [
                  if (!largeTitle)
                    IconButton(
                      tooltip: 'Back',
                      onPressed: () => back(context),
                      icon: const Icon(Icons.west, size: 22),
                    ),
                  if (largeTitle) const SizedBox(width: 8),
                  Expanded(
                    child: largeTitle
                        ? UnderlinedTitle(title)
                        : Text(
                            title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                  ),
                  ?actions,
                  if (largeTitle && title == 'Discover')
                    IconButton(
                      tooltip: 'Search',
                      onPressed: () => go(context, '/search'),
                      icon: const Icon(Icons.search, size: 23),
                    ),
                  if (cart)
                    const CartButton()
                  else if (!largeTitle)
                    const SizedBox(width: 48),
                ],
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    ),
    bottomNavigationBar:
        bottom ?? (tab == null ? null : ShopNavigation(index: tab!)),
  );
}

class UnderlinedTitle extends StatelessWidget {
  const UnderlinedTitle(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Stack(
      children: [
        Positioned(
          bottom: 1,
          right: 0,
          child: Container(
            width: text.length * 8.5,
            height: 4,
            decoration: BoxDecoration(
              color: FurniteTheme.yellow,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        Text(text, style: Theme.of(context).textTheme.headlineMedium),
      ],
    ),
  );
}

class CartButton extends StatelessWidget {
  const CartButton({super.key});
  @override
  Widget build(BuildContext context) {
    final state = ShopScope.of(context);
    return Container(
      width: 50,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [FurniteTheme.shadow],
      ),
      child: IconButton(
        tooltip: 'Shopping cart',
        onPressed: () => go(context, '/cart'),
        icon: Badge(
          isLabelVisible: state.itemCount > 0,
          backgroundColor: FurniteTheme.yellow,
          textColor: FurniteTheme.ink,
          label: Text('${state.itemCount}'),
          child: const Icon(Icons.shopping_cart_outlined, size: 22),
        ),
      ),
    );
  }
}

class ShopNavigation extends StatelessWidget {
  const ShopNavigation({super.key, required this.index});
  final int index;
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Color(0x08000000),
          blurRadius: 18,
          offset: Offset(0, -4),
        ),
      ],
    ),
    child: SafeArea(
      top: false,
      child: SizedBox(
        height: 74,
        child: Row(
          children: [
            for (final (i, item) in const [
              ('/', 'Home', Icons.storefront_outlined),
              ('/search', 'Search', Icons.search),
              ('/saved', 'Saved', Icons.favorite_border),
              ('/profile', 'Profile', Icons.person_outline),
            ].indexed)
              Expanded(
                child: Semantics(
                  selected: i == index,
                  button: true,
                  label: '${item.$2} tab',
                  child: InkWell(
                    onTap: () {
                      if (i != index) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          item.$1,
                          (_) => false,
                        );
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (i == 3)
                          const CircleAvatar(
                            radius: 14,
                            backgroundImage: AssetImage(
                              'assets/images/avatar.jpg',
                            ),
                          )
                        else
                          Icon(
                            item.$3,
                            size: 24,
                            color: i == index
                                ? FurniteTheme.ink
                                : const Color(0xFFBDBDBC),
                          ),
                        const SizedBox(height: 5),
                        if (i == index)
                          Text(
                            item.$2,
                            style: const TextStyle(
                              color: FurniteTheme.ink,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 56,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: FurniteTheme.yellow,
        disabledBackgroundColor: const Color(0xFFE5E5E5),
        foregroundColor: FurniteTheme.ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          if (icon != null) ...[const SizedBox(width: 12), Icon(icon)],
        ],
      ),
    ),
  );
}

class BottomAction extends StatelessWidget {
  const BottomAction(this.label, {super.key, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: FurniteTheme.yellow,
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    child: SafeArea(
      top: false,
      child: SizedBox(
        height: 70,
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: FurniteTheme.ink,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    ),
  );
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: const [FurniteTheme.shadow],
    ),
    child: child,
  );
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
      if (action != null)
        TextButton(
          onPressed: onAction,
          child: Text(action!, style: const TextStyle(fontSize: 12)),
        ),
    ],
  );
}

class ProductTile extends StatelessWidget {
  const ProductTile(this.product, {super.key, this.height = 204});
  final Product product;
  final double height;
  @override
  Widget build(BuildContext context) {
    final state = ShopScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => go(context, '/product/${product.id}'),
              child: Container(
                height: height,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: product.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(10),
                child: Hero(
                  tag: 'product-${product.id}',
                  child: Image.asset(product.asset, fit: BoxFit.contain),
                ),
              ),
            ),
            Positioned(
              top: 3,
              right: 3,
              child: IconButton(
                tooltip: state.saved.contains(product.id)
                    ? 'Unsave ${product.name}'
                    : 'Save ${product.name}',
                onPressed: () => state.toggleSaved(product.id),
                icon: Icon(
                  state.saved.contains(product.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: state.saved.contains(product.id)
                      ? const Color(0xFFEF6262)
                      : const Color(0xFFBDBDBC),
                  size: 21,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          money(product.price),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: FurniteTheme.ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 16),
      ],
    );
  }
}

class ProductMasonry extends StatelessWidget {
  const ProductMasonry(this.items, {super.key});
  final List<Product> items;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (int column = 0; column < 2; column++) ...[
        if (column == 1) const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              for (int i = column; i < items.length; i += 2)
                ProductTile(items[i], height: (i % 3 == 1) ? 132 : 204),
            ],
          ),
        ),
      ],
    ],
  );
}

class ConceptCard extends StatelessWidget {
  const ConceptCard(this.concept, {super.key});
  final RoomConcept concept;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => go(context, '/concept/${concept.id}'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: [
              Image.asset(
                concept.asset,
                height: 190,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black54],
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.chair_outlined, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Living room',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Spacer(),
                      Text(
                        'From \$12.00',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(concept.name, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(concept.description, maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 24),
      ],
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.onAction,
  });
  final IconData icon;
  final String title, message;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF8E7),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 62, color: FurniteTheme.orange),
          ),
          const SizedBox(height: 28),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          if (action != null) ...[
            const SizedBox(height: 28),
            PrimaryButton(action!, onPressed: onAction),
          ],
        ],
      ),
    ),
  );
}

class QuantityControl extends StatelessWidget {
  const QuantityControl({
    super.key,
    required this.value,
    required this.onChanged,
    this.allowZero = false,
  });
  final int value;
  final bool allowZero;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        tooltip: 'Decrease quantity',
        onPressed: value > (allowZero ? 0 : 1)
            ? () => onChanged(value - 1)
            : null,
        icon: const Icon(Icons.remove, size: 18),
        style: IconButton.styleFrom(
          side: const BorderSide(color: FurniteTheme.muted),
          minimumSize: const Size(36, 36),
          maximumSize: const Size(36, 36),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      SizedBox(
        width: 38,
        child: Text(
          '$value',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            color: FurniteTheme.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      IconButton(
        tooltip: 'Increase quantity',
        onPressed: value < 99 ? () => onChanged(value + 1) : null,
        icon: const Icon(Icons.add, size: 18),
        style: IconButton.styleFrom(
          side: const BorderSide(color: FurniteTheme.muted),
          minimumSize: const Size(36, 36),
          maximumSize: const Size(36, 36),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    ],
  );
}
