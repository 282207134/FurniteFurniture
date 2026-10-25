import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../data/catalog.dart';
import '../state/shop_state.dart';
import '../widgets/shop_widgets.dart';

const colorOptions = [
  ('Silver', Color(0xFFB2C0D0)),
  ('Copper', Color(0xFFEF6565)),
  ('Yellow', FurniteTheme.yellow),
  ('Charcoal', Color(0xFF4D585E)),
];

class ColorPicker extends StatelessWidget {
  const ColorPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.primaryColor = 'Silver',
  });
  final String value;
  final String primaryColor;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) {
    final options = colorOptions.any((e) => e.$1 == primaryColor)
        ? colorOptions
        : [
            (
              primaryColor,
              primaryColor == 'Gold'
                  ? const Color(0xFFD9A442)
                  : const Color(0xFF4B9196),
            ),
            ...colorOptions.skip(1),
          ];
    return Row(
      children: [
        for (final option in options)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Semantics(
              label: '${option.$1} color',
              selected: value == option.$1,
              button: true,
              child: InkWell(
                onTap: () => onChanged(option.$1),
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  width: 42,
                  height: 42,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: value == option.$1
                        ? [FurniteTheme.shadow]
                        : null,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: option.$2,
                    ),
                    child: value == option.$1
                        ? const Icon(Icons.check, size: 18, color: Colors.white)
                        : null,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class ProductScreen extends StatefulWidget {
  const ProductScreen(this.product, {super.key});
  final Product product;
  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int quantity = 1;
  late String color = widget.product.color;
  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final state = ShopScope.of(context);
    return PageFrame(
      title: '',
      background: const Color(0xFFF2F4F9),
      actions: IconButton(
        tooltip: 'Save product',
        onPressed: () => state.toggleSaved(p.id),
        icon: Icon(
          state.saved.contains(p.id) ? Icons.favorite : Icons.favorite_border,
          color: state.saved.contains(p.id)
              ? const Color(0xFFEF6262)
              : FurniteTheme.muted,
        ),
      ),
      bottom: BottomAction(
        'Add To Cart   ${money(p.price * quantity)}',
        onPressed: () {
          state.add(p, color: color, quantity: quantity);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$quantity item(s) added to your cart'),
              action: SnackBarAction(
                label: 'View cart',
                textColor: FurniteTheme.yellow,
                onPressed: () => go(context, '/cart'),
              ),
            ),
          );
        },
      ),
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Text(
              'Pathfinder',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: FurniteTheme.ink,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Concept',
              style: TextStyle(fontSize: 22, color: FurniteTheme.ink),
            ),
          ),
          SizedBox(
            height: 340,
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 155,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(40),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 65,
                      vertical: 16,
                    ),
                    child: Hero(
                      tag: 'product-${p.id}',
                      child: Image.asset(p.asset, fit: BoxFit.contain),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 22),
                  child: Row(
                    children: [
                      for (final item in const [
                        (Icons.straighten, '31″ x 23″'),
                        (Icons.palette_outlined, '4 colors'),
                        (Icons.bubble_chart_outlined, 'Metal / Plastic'),
                      ])
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: SurfaceCard(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Icon(
                                  item.$1,
                                  color: FurniteTheme.muted,
                                  size: 24,
                                ),
                                const SizedBox(width: 10),
                                Text(item.$2),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Living room furniture',
                        style: TextStyle(color: FurniteTheme.ink),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'A thoughtful touch for your favorite corner. With an adjustable shade and a timeless silhouette, this lamp brings a warm, focused glow to everyday living.',
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Color',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text('4 available · $color'),
                                const SizedBox(height: 10),
                                FittedBox(
                                  alignment: Alignment.centerLeft,
                                  fit: BoxFit.scaleDown,
                                  child: ColorPicker(
                                    primaryColor: p.color,
                                    value: color,
                                    onChanged: (value) =>
                                        setState(() => color = value),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quantity',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              const Text('Storage: 999+'),
                              const SizedBox(height: 10),
                              QuantityControl(
                                value: quantity,
                                onChanged: (value) =>
                                    setState(() => quantity = value),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      SectionHeading(
                        'Similar Product',
                        action: 'View All',
                        onAction: () => go(context, '/products'),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height:
                            204 + MediaQuery.textScalerOf(context).scale(100),
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: 3,
                          separatorBuilder: (_, _) => const SizedBox(width: 16),
                          itemBuilder: (_, index) {
                            final similar = products
                                .where((e) => e.id != p.id)
                                .toList();
                            return SizedBox(
                              width: 156,
                              child: ProductTile(similar[index]),
                            );
                          },
                        ),
                      ),
                      SectionHeading(
                        'Pathfinder Concept',
                        action: 'Explore',
                        onAction: () => go(context, '/concept/pathfinder'),
                      ),
                      const SizedBox(height: 18),
                      const RoomGallery(),
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
}

const galleryImages = [
  'gallery_room',
  'gallery_lamp',
  'gallery_cat',
  'gallery_corner',
  'gallery_desk',
  'gallery_sofa',
];

void openGallery(BuildContext context, int initial) => Navigator.push(
  context,
  MaterialPageRoute<void>(builder: (_) => GalleryScreen(initial: initial)),
);

class RoomGallery extends StatelessWidget {
  const RoomGallery({super.key});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      InkWell(
        onTap: () => openGallery(context, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(
            'assets/images/gallery_room.jpg',
            height: 154,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ),
      const SizedBox(height: 12),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: _galleryTile(context, 1, 224)),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _galleryTile(context, 2, 106),
                const SizedBox(height: 12),
                _galleryTile(context, 3, 106),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(child: _galleryTile(context, 4, 139)),
          const SizedBox(width: 12),
          Expanded(child: _galleryTile(context, 5, 139)),
        ],
      ),
    ],
  );
  Widget _galleryTile(BuildContext context, int index, double height) =>
      InkWell(
        onTap: () => openGallery(context, index),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(
            'assets/images/${galleryImages[index]}.jpg',
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      );
}

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key, this.initial = 0});
  final int initial;
  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late int index = widget.initial;
  late final controller = PageController(initialPage: widget.initial);
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF24272B),
    body: SafeArea(
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Close gallery',
                onPressed: () => back(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
              const Spacer(),
              Text(
                '${index + 1} / ${galleryImages.length}',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(width: 24),
            ],
          ),
          Expanded(
            child: PageView.builder(
              controller: controller,
              itemCount: galleryImages.length,
              onPageChanged: (value) => setState(() => index = value),
              itemBuilder: (_, i) => InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: Image.asset(
                    'assets/images/${galleryImages[i]}.jpg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Pathfinder Concept  ·  Swipe to explore',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    ),
  );
}

class ConceptScreen extends StatefulWidget {
  const ConceptScreen(this.concept, {super.key});
  final RoomConcept concept;
  @override
  State<ConceptScreen> createState() => _ConceptScreenState();
}

class _ConceptScreenState extends State<ConceptScreen> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    final room = widget.concept;
    final state = ShopScope.of(context);
    return PageFrame(
      title: '',
      actions: IconButton(
        tooltip: 'Save concept',
        onPressed: () => state.toggleConcept(room.id),
        icon: Icon(
          state.savedConcepts.contains(room.id)
              ? Icons.favorite
              : Icons.favorite_border,
          color: const Color(0xFFEF6262),
        ),
      ),
      bottom: BottomAction(
        'Shop this concept   ${money(products.take(3).fold<int>(0, (sum, p) => sum + p.price))}',
        onPressed: () {
          for (final p in products.take(3)) {
            state.add(p);
          }
          go(context, '/cart');
        },
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        children: [
          Text(room.name, style: Theme.of(context).textTheme.titleLarge),
          const Text(
            'Concept',
            style: TextStyle(fontSize: 22, color: FurniteTheme.ink),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 224,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: InkWell(
                    onTap: () => openGallery(context, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        room.asset,
                        height: 224,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          'assets/images/gallery_sofa.jpg',
                          height: 106,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () => openGallery(context, 0),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              image: const DecorationImage(
                                image: AssetImage(
                                  'assets/images/gallery_corner.jpg',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              color: Colors.black45,
                              child: const Text(
                                '+5\nPhotos',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final (i, label) in [
                  'Explore',
                  'Design Features',
                  'Deco',
                ].indexed)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TextButton(
                      onPressed: () => setState(() => tab = i),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          color: i == tab
                              ? FurniteTheme.ink
                              : const Color(0xFFBDBDBC),
                          fontWeight: i == tab
                              ? FontWeight.w700
                              : FontWeight.w400,
                          decoration: i == tab
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
            const Text(
              'Living room',
              style: TextStyle(color: FurniteTheme.ink),
            ),
            const SizedBox(height: 16),
            Text(room.description),
            const SizedBox(height: 24),
            const RoomGallery(),
          ],
          if (tab == 1) ...[
            const Text(
              'Thoughtfully designed for living',
              style: TextStyle(color: FurniteTheme.ink),
            ),
            const SizedBox(height: 16),
            Text(room.description),
            const SizedBox(height: 24),
            for (final (i, title) in [
              'Progressive Look',
              'Comfortable',
              'Modern Design',
            ].indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: InkWell(
                  onTap: () => showModalBottomSheet<void>(
                    context: context,
                    showDragHandle: true,
                    isScrollControlled: true,
                    builder: (_) => Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/images/${galleryImages[i + 1]}.jpg',
                              height: 230,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Soft cushions, considered proportions and enduring materials come together to create comfort that feels effortless.',
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  child: SurfaceCard(
                    padding: EdgeInsets.zero,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/${galleryImages[i + 1]}.jpg',
                            height: 150,
                            width: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Every detail, made for everyday comfort.',
                                  style: TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Detail  →',
                                  style: TextStyle(color: FurniteTheme.ink),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
          if (tab == 2) ProductMasonry(products),
        ],
      ),
    );
  }
}
