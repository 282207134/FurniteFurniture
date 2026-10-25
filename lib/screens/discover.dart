import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../data/catalog.dart';
import '../state/shop_state.dart';
import '../widgets/shop_widgets.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});
  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  int slide = 0;
  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Discover',
    largeTitle: true,
    tab: 0,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      children: [
        SizedBox(
          height: 158,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: PageView(
              onPageChanged: (value) => setState(() => slide = value),
              children: [
                for (int i = 0; i < 3; i++)
                  InkWell(
                    onTap: () => go(
                      context,
                      i == 0 ? '/category/Armchair' : '/products',
                    ),
                    child: i == 0
                        ? Image.asset(
                            'assets/images/promotion.png',
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: i == 1
                                ? const Color(0xFFF4E8DC)
                                : const Color(0xFFE7ECE7),
                            padding: const EdgeInsets.all(22),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        i == 1
                                            ? 'Light up your home'
                                            : 'Made for slow living',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleLarge,
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Thoughtful design. Everyday comfort.',
                                      ),
                                    ],
                                  ),
                                ),
                                Image.asset(
                                  products[i].asset,
                                  width: 94,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                          ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 9),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < 3; i++)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: slide == i
                      ? FurniteTheme.yellow
                      : const Color(0xFFC4C4C4),
                ),
              ),
          ],
        ),
        const SizedBox(height: 22),
        SectionHeading(
          'Categories',
          action: 'View all',
          onAction: () => go(context, '/categories'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final (index, category) in [
              categories[0],
              categories[1],
              categories[3],
            ].indexed) ...[
              if (index > 0) const SizedBox(width: 14),
              Expanded(
                child: InkWell(
                  onTap: () => go(context, '/category/${category.name}'),
                  child: SurfaceCard(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        Icon(
                          category.icon,
                          color: const Color(0xFF737D94),
                          size: 27,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          category.name,
                          style: const TextStyle(color: Color(0xFF737D94)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 32),
        const SectionHeading('Featured Concept'),
        const SizedBox(height: 18),
        for (final room in concepts.take(3)) ConceptCard(room),
        const SectionHeading('Trending Concept'),
        const SizedBox(height: 18),
        for (final room in concepts.skip(3)) ConceptCard(room),
      ],
    ),
  );
}

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Categories',
    cart: false,
    child: ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      itemCount: categories.length,
      separatorBuilder: (_, _) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final category = categories[index];
        return InkWell(
          onTap: () => go(context, '/category/${category.name}'),
          child: Container(
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                left: BorderSide(color: category.accent, width: 4),
              ),
              borderRadius: BorderRadius.circular(4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(category.icon, size: 28),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: FurniteTheme.ink,
                    ),
                  ),
                ),
                Text(
                  '${category.count} products',
                  style: const TextStyle(
                    color: Color(0xFFBDBDBC),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

class CategoryScreen extends StatelessWidget {
  const CategoryScreen(this.name, {super.key});
  final String name;
  @override
  Widget build(BuildContext context) {
    const types = [
      'Table Lamps',
      'Ceiling Lamps',
      'Sconces',
      'Floor Lamps',
      'Light Decos',
      'Garlands',
    ];
    return PageFrame(
      title: name,
      child: name != 'Light'
          ? EmptyState(
              icon: categories.firstWhere((e) => e.name == name).icon,
              title: '$name collection',
              message:
                  'This collection is coming soon.\nExplore our lighting collection in the meantime.',
              action: 'Explore Light',
              onAction: () => go(context, '/category/Light'),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: types.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 24,
                crossAxisSpacing: 16,
                childAspectRatio: .93,
              ),
              itemBuilder: (context, index) => InkWell(
                onTap: () => go(
                  context,
                  '/products?type=${Uri.encodeComponent(types[index])}',
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: products[index].background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.asset(
                          'assets/images/category_$index.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      types[index],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: FurniteTheme.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key, this.initialType = 'Table Lamps'});
  final String initialType;
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late String type = widget.initialType;
  String sort = 'Popular';
  @override
  Widget build(BuildContext context) {
    final items = [
      products[1],
      products[3],
      products[4],
      products[2],
      products[0],
      products[5],
    ];
    if (sort == 'Price: Low to High') {
      items.sort((a, b) => a.price.compareTo(b.price));
    }
    if (sort == 'Price: High to Low') {
      items.sort((a, b) => b.price.compareTo(a.price));
    }
    return PageFrame(
      title: 'Light',
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                for (final label in [
                  'Table Lamps',
                  'Ceiling',
                  'Sconces',
                  'Floor',
                  'Deco',
                ])
                  TextButton(
                    onPressed: () => setState(
                      () => type = label == 'Ceiling'
                          ? 'Ceiling Lamps'
                          : label == 'Floor'
                          ? 'Floor Lamps'
                          : label,
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: type.startsWith(label.split(' ').first)
                            ? FurniteTheme.ink
                            : const Color(0xFFBDBDBC),
                        fontSize: 16,
                        fontWeight: type.startsWith(label.split(' ').first)
                            ? FontWeight.w700
                            : FontWeight.w400,
                        decoration: type.startsWith(label.split(' ').first)
                            ? TextDecoration.underline
                            : null,
                        decorationColor: FurniteTheme.yellow,
                        decorationThickness: 3,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: type != 'Table Lamps'
                ? EmptyState(
                    icon: Icons.light_outlined,
                    title: 'More light, coming soon',
                    message: 'Our $type collection is on its way.',
                    action: 'Browse Table Lamps',
                    onAction: () => setState(() => type = 'Table Lamps'),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: DropdownButton<String>(
                          value: sort,
                          underline: const SizedBox(),
                          style: const TextStyle(
                            color: Color(0xFF737D94),
                            fontFamily: 'Muli',
                            fontSize: 14,
                          ),
                          items:
                              [
                                    'Popular',
                                    'Price: Low to High',
                                    'Price: High to Low',
                                  ]
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (s) => setState(() => sort = s!),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ProductMasonry(items),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = controller.text.trim().toLowerCase();
    final items = products
        .where(
          (p) =>
              '${p.name} ${p.color} light lamp'.toLowerCase().contains(query),
        )
        .toList();
    final rooms = concepts
        .where((r) => '${r.name} living room'.toLowerCase().contains(query))
        .toList();
    return PageFrame(
      title: 'Search',
      largeTitle: true,
      tab: 1,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: SurfaceCard(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: controller,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search for item / concept',
                  prefixIcon: const Icon(Icons.search, size: 21),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            controller.clear();
                            setState(() {});
                          },
                        ),
                ),
              ),
            ),
          ),
          Expanded(
            child: items.isEmpty && rooms.isEmpty
                ? EmptyState(
                    icon: Icons.search_off,
                    title: 'No results found',
                    message: 'Try a different name, material or color.',
                    action: 'Clear search',
                    onAction: () {
                      controller.clear();
                      setState(() {});
                    },
                  )
                : ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      if (query.isEmpty) ...[
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final suggestion in [
                              'Chair',
                              'Living room',
                              'Kitchen',
                              'Main hall',
                              'Bedroom',
                              'Light',
                              'Home Deco',
                              'Sconces',
                            ])
                              ActionChip(
                                label: Text(suggestion),
                                backgroundColor: Colors.white,
                                side: const BorderSide(
                                  color: FurniteTheme.line,
                                ),
                                onPressed: () {
                                  controller.text = suggestion;
                                  setState(() {});
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                      if (items.isNotEmpty) ...[
                        const SectionHeading('Item'),
                        const SizedBox(height: 18),
                        ProductMasonry(items),
                      ],
                      if (rooms.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const SectionHeading('Concept'),
                        const SizedBox(height: 18),
                        for (final room in rooms) ConceptCard(room),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});
  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  String filter = 'All';
  @override
  Widget build(BuildContext context) {
    final state = ShopScope.of(context);
    final items = products.where((p) => state.saved.contains(p.id)).toList();
    final rooms = concepts
        .where((c) => state.savedConcepts.contains(c.id))
        .toList();
    return PageFrame(
      title: 'Saved',
      largeTitle: true,
      tab: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                for (final tab in ['All', 'Concept', 'Item'])
                  Padding(
                    padding: const EdgeInsets.only(right: 18),
                    child: TextButton(
                      onPressed: () => setState(() => filter = tab),
                      child: Text(
                        tab,
                        style: TextStyle(
                          color: filter == tab
                              ? FurniteTheme.ink
                              : FurniteTheme.muted,
                          fontWeight: filter == tab
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty && rooms.isEmpty
                ? EmptyState(
                    icon: Icons.favorite_border,
                    title: 'Make room for your favorites',
                    message: 'Tap a heart to save the pieces you love.',
                    action: 'Start exploring',
                    onAction: () => go(context, '/products'),
                  )
                : ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      if (filter != 'Item' && rooms.isNotEmpty) ...[
                        const SectionHeading('Concept'),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 300,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: rooms.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 16),
                            itemBuilder: (_, i) => SizedBox(
                              width: 300,
                              child: ConceptCard(rooms[i]),
                            ),
                          ),
                        ),
                      ],
                      if (filter != 'Concept' && items.isNotEmpty) ...[
                        const SectionHeading('Item'),
                        const SizedBox(height: 18),
                        ProductMasonry(items),
                      ],
                      if ((filter == 'Item' && items.isEmpty) ||
                          (filter == 'Concept' && rooms.isEmpty))
                        const Padding(
                          padding: EdgeInsets.all(30),
                          child: Text('Nothing saved here yet.'),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
