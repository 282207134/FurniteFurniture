import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:furnite/core/validation.dart';
import 'package:furnite/data/catalog.dart';
import 'package:furnite/state/shop_state.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'cart merges matching variants and calculates in integer cents',
    () async {
      final state = await ShopState.load();
      state.add(products.first, quantity: 2);
      state.add(products.first);
      state.add(products.first, color: 'Copper');
      expect(state.cart.length, 2);
      expect(state.itemCount, 4);
      expect(state.subtotal, 4800);
      expect(state.total, 6555);
      state.setQuantity(state.cart.first, 500);
      expect(state.cart.first.quantity, 99);
    },
  );
  test('discount, removal, and checkout keep totals consistent', () async {
    final state = await ShopState.load();
    for (final p in products.take(3)) {
      state.add(p);
    }
    expect(state.subtotal, 21700);
    expect(state.applyPromo('invalid'), false);
    expect(state.applyPromo(' furnite10 '), true);
    expect(state.discount, 2170);
    expect(state.total, 21285);
    state.customize(state.cart.first, color: 'Copper', quantity: 1);
    expect(state.promo, 'FURNITE10');
    expect(state.total, 21285);
    final order = state.placeOrder()!;
    expect(order.total, 21285);
    expect(order.lines.length, 3);
    expect(state.itemCount, 0);
    expect(state.total, 0);
    expect(state.promo, null);
    expect(state.placeOrder(), null);
    expect(state.orders.length, 1);
    state.add(products.first);
    expect(order.lines.first.quantity, 1);
  });
  test(
    'saved items, profile, cart, orders and masked card survive reload',
    () async {
      final state = await ShopState.load();
      state.toggleSaved('pathfinder');
      state.toggleConcept('pathfinder');
      state.add(products.first);
      state.placeOrder();
      state.add(products[1], color: 'Copper', quantity: 2);
      state.saveCard('4242');
      state.updateProfile(
        fullName: 'Test User',
        contactEmail: 'test@example.com',
        contactPhone: '123456789',
        street: '21 Test Road',
        location: 'Tokyo',
      );
      await state.flush();
      final restored = await ShopState.load();
      expect(restored.saved.contains('pathfinder'), true);
      expect(restored.savedConcepts.contains('pathfinder'), true);
      expect(restored.orders.single.total, 2955);
      expect(restored.itemCount, 2);
      expect(restored.name, 'Test User');
      expect(restored.cardLast4, '4242');
      restored.setQuantity(restored.cart.first, 0);
      expect(restored.shipping, 0);
    },
  );
  test('corrupt stored data does not prevent launch', () async {
    SharedPreferences.setMockInitialValues({'furnite.state.v1': 'broken json'});
    expect((await ShopState.load()).cart, isEmpty);
  });
  test('forms reject invalid email, expired cards and invalid checksums', () {
    expect(Validate.email('hello'), isNotNull);
    expect(Validate.email('alice@example.com'), isNull);
    expect(Validate.card('4242 4242 4242 4242'), isNull);
    expect(Validate.card('4242 4242 4242 4243'), isNotNull);
    expect(Validate.expiry('12/20'), isNotNull);
    expect(Validate.expiry('13/30'), isNotNull);
    expect(Validate.expiry('12/30'), isNull);
  });
}
