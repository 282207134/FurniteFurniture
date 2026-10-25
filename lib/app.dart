import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'data/catalog.dart';
import 'screens/auth.dart';
import 'screens/cart.dart';
import 'screens/checkout.dart';
import 'screens/discover.dart';
import 'screens/product.dart';
import 'screens/profile.dart';
import 'state/shop_state.dart';
import 'widgets/shop_widgets.dart';

class FurniteApp extends StatelessWidget {
  const FurniteApp({super.key, required this.state, this.initialRoute});
  final ShopState state;
  final String? initialRoute;
  @override
  Widget build(BuildContext context) => ShopScope(
    state: state,
    child: MaterialApp(
      title: 'Furnite',
      debugShowCheckedModeBanner: false,
      theme: FurniteTheme.data,
      initialRoute: initialRoute,
      onGenerateRoute: _route,
      onGenerateInitialRoutes: (route) => [_route(RouteSettings(name: route))],
      builder: (context, child) => ColoredBox(
        color: const Color(0xFFF1F2F5),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: child,
          ),
        ),
      ),
    ),
  );
  Route<dynamic> _route(RouteSettings settings) {
    final uri = Uri.tryParse(settings.name ?? '/') ?? Uri(path: '/');
    final parts = uri.pathSegments;
    final Widget screen;
    if (uri.path == '/') {
      screen = const DiscoverScreen();
    } else if (uri.path == '/categories') {
      screen = const CategoriesScreen();
    } else if (parts.firstOrNull == 'category' &&
        parts.length == 2 &&
        categories.any((e) => e.name == parts[1])) {
      screen = CategoryScreen(parts[1]);
    } else if (uri.path == '/products') {
      screen = ProductsScreen(
        initialType: uri.queryParameters['type'] ?? 'Table Lamps',
      );
    } else if (uri.path == '/search') {
      screen = const SearchScreen();
    } else if (uri.path == '/saved') {
      screen = const SavedScreen();
    } else if (parts.firstOrNull == 'product' &&
        parts.length == 2 &&
        products.any((p) => p.id == parts[1])) {
      screen = ProductScreen(productById(parts[1]));
    } else if (parts.firstOrNull == 'concept' &&
        parts.length == 2 &&
        concepts.any((p) => p.id == parts[1])) {
      screen = ConceptScreen(concepts.firstWhere((c) => c.id == parts[1]));
    } else if (uri.path == '/gallery') {
      screen = const GalleryScreen();
    } else if (uri.path == '/cart') {
      screen = const CartScreen();
    } else if (uri.path == '/checkout') {
      screen = const CheckoutScreen();
    } else if (uri.path == '/success') {
      screen = SuccessScreen(
        settings.arguments as ShopOrder? ?? state.orders.firstOrNull,
      );
    } else if (uri.path == '/profile') {
      screen = ProfileScreen(
        initialTab: (int.tryParse(uri.queryParameters['tab'] ?? '') ?? 0).clamp(
          0,
          3,
        ),
      );
    } else if (uri.path == '/profile/edit') {
      screen = const ProfileEditScreen();
    } else if (uri.path == '/card/add') {
      screen = const AddCardScreen();
    } else if (uri.path == '/signin' || uri.path == '/signup') {
      screen = AuthScreen(signUp: uri.path == '/signup');
    } else if (uri.path == '/recovery') {
      screen = const RecoveryScreen();
    } else {
      screen = Builder(
        builder: (context) => PageFrame(
          title: 'Furnite',
          cart: false,
          child: EmptyState(
            icon: Icons.explore_outlined,
            title: 'Page not found',
            message: 'Let’s find your way home.',
            action: 'Back to home',
            onAction: () => go(context, '/'),
          ),
        ),
      );
    }
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (_) => screen,
    );
  }
}
