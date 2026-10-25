import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:furnite/app.dart';
import 'package:furnite/data/catalog.dart';
import 'package:furnite/state/shop_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader('Muli')
      ..addFont(rootBundle.load('assets/fonts/Mulish.ttf'));
    await font.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  Future<ShopState> fresh() async {
    SharedPreferences.setMockInitialValues({});
    return ShopState.load();
  }

  Future<void> open(WidgetTester tester, ShopState state, String route) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(FurniteApp(state: state, initialRoute: route));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: route);
  }

  testWidgets('all routes render and checkout creates a discounted order', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final state = await fresh();
    final routes = {
      '01_home': '/',
      '02_categories': '/categories',
      '03_light_categories': '/category/Light',
      '04_products': '/products',
      '05_product_detail': '/product/pathfinder',
      '06_concept': '/concept/pathfinder',
      '07_search': '/search',
      '09_saved': '/saved',
      '10_cart_empty': '/cart',
      '17_profile': '/profile',
      '18_profile_edit': '/profile/edit',
      '19_voucher': '/profile?tab=2',
      '20_card_empty': '/profile?tab=3',
      '21_add_card': '/card/add',
      '22_signin': '/signin',
      '23_signup': '/signup',
      '24_recovery': '/recovery',
      '27_gallery': '/gallery',
      '28_collection_empty': '/category/Armchair',
    };
    for (final entry in routes.entries) {
      await open(tester, state, entry.value);
    }
    await open(tester, state, '/search');
    await tester.enterText(find.byType(TextField), 'no matching furniture');
    await tester.pumpAndSettle();
    expect(find.text('No results found'), findsOneWidget);
    await open(tester, state, '/concept/pathfinder');
    await tester.tap(find.text('Design Features'));
    await tester.pumpAndSettle();
    for (final p in products.take(3)) {
      state.add(p);
    }
    await open(tester, state, '/cart');
    await tester.tap(find.text('Customize').first);
    await tester.pumpAndSettle();
    await open(tester, state, '/checkout');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Payment Method'), findsOneWidget);
    await tester.tap(find.text('Cash'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Order Summary'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('+ Promo code or voucher'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('+ Promo code or voucher'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'FURNITE10');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(state.discount, 2170);
    await tester.tap(find.text('Place Order'));
    await tester.pumpAndSettle();
    expect(state.orders.length, 1);
    expect(state.cart, isEmpty);
    await open(tester, state, '/profile');
    state.saveCard('4242');
    await open(tester, state, '/profile?tab=3');
    await open(tester, state, '/recovery');
    await tester.enterText(find.byType(TextFormField), 'alice@example.com');
    await tester.tap(find.text('Get the code'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '246810');
    await tester.tap(find.text('Verify code'));
    await tester.pumpAndSettle();
    await open(tester, state, '/profile?tab=1');
  });
  testWidgets('product controls update saved items and cart', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final state = await fresh();
    await open(tester, state, '/product/pathfinder');
    await tester.tap(find.byTooltip('Save product'));
    await tester.pumpAndSettle();
    expect(state.saved.contains('pathfinder'), true);
    await tester.tap(find.text('Add To Cart   \$ 12.00'));
    await tester.pumpAndSettle();
    expect(state.itemCount, 1);
    await tester.tap(find.text('View cart'));
    await tester.pumpAndSettle();
    expect(find.text('Your Cart'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove Pathfinder LT-54'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(find.text('Your cart is empty'), findsOneWidget);
  });
  testWidgets('phone widths and larger text remain usable', (tester) async {
    final state = await fresh();
    for (final size in [const Size(320, 700), const Size(520, 900)]) {
      await tester.binding.setSurfaceSize(size);
      for (final route in [
        '/',
        '/products',
        '/product/pathfinder',
        '/profile',
        '/signin',
        '/categories',
      ]) {
        await open(tester, state, route);
      }
    }
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    for (final route in ['/', '/product/pathfinder', '/profile', '/signin']) {
      await open(tester, state, route);
    }
  });
}
