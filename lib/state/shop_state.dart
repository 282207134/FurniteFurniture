import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/catalog.dart';

class CartLine {
  CartLine(this.productId, this.color, this.quantity);
  final String productId, color;
  int quantity;
  Product get product => productById(productId);
  int get total => product.price * quantity;
  Map<String, dynamic> toJson() => {
    'id': productId,
    'color': color,
    'qty': quantity,
  };
  factory CartLine.fromJson(Map<String, dynamic> value) => CartLine(
    value['id'] as String,
    value['color'] as String,
    value['qty'] as int,
  );
}

class ShopOrder {
  const ShopOrder(this.id, this.date, this.lines, this.total);
  final String id, date;
  final List<CartLine> lines;
  final int total;
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'lines': lines.map((e) => e.toJson()).toList(),
    'total': total,
  };
  factory ShopOrder.fromJson(Map<String, dynamic> value) => ShopOrder(
    value['id'] as String,
    value['date'] as String,
    (value['lines'] as List)
        .map((e) => CartLine.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    value['total'] as int,
  );
}

class ShopState extends ChangeNotifier {
  ShopState(this._preferences);
  final SharedPreferences _preferences;
  final List<CartLine> _cart = [];
  final Set<String> _saved = {'gile', 'golden', 'nordic'};
  final Set<String> _savedConcepts = {'minato', 'monument'};
  final List<ShopOrder> _orders = [];
  List<CartLine> get cart => List.unmodifiable(_cart);
  Set<String> get saved => Set.unmodifiable(_saved);
  Set<String> get savedConcepts => Set.unmodifiable(_savedConcepts);
  List<ShopOrder> get orders => List.unmodifiable(_orders);
  String name = "Alice O'Donnell",
      email = 'Dolice@gmail.com',
      phone = '(070) 0435 2524';
  String address = '31 Brynglas Road', city = 'Glewstone, Great Britain';
  bool signedIn = false;
  String? cardLast4, promo, persistenceError;
  Future<void> _pendingSave = Future.value();

  static Future<ShopState> load() async {
    final state = ShopState(await SharedPreferences.getInstance());
    final source = state._preferences.getString('furnite.state.v1');
    if (source != null) {
      try {
        final data = jsonDecode(source) as Map<String, dynamic>;
        state._cart.addAll(
          (data['cart'] as List)
              .map((e) => CartLine.fromJson(e))
              .where(
                (e) =>
                    products.any((p) => p.id == e.productId) &&
                    e.quantity > 0 &&
                    e.quantity <= 99,
              ),
        );
        state._saved
          ..clear()
          ..addAll(List<String>.from(data['saved']));
        state._savedConcepts
          ..clear()
          ..addAll(List<String>.from(data['concepts']));
        state._orders.addAll(
          (data['orders'] as List).map((e) => ShopOrder.fromJson(e)),
        );
        state.name = data['name'];
        state.email = data['email'];
        state.phone = data['phone'];
        state.address = data['address'];
        state.city = data['city'];
        state.signedIn = data['signedIn'] ?? false;
        state.cardLast4 = data['card'];
        state.promo = data['promo'];
      } on Object {
        state._cart.clear();
        state._orders.clear();
      }
    }
    return state;
  }

  int get itemCount => _cart.fold(0, (sum, line) => sum + line.quantity);
  int get subtotal => _cart.fold(0, (sum, line) => sum + line.total);
  int get shipping => _cart.isEmpty ? 0 : 1755;
  int get discount => promo == null ? 0 : (subtotal * 0.1).round();
  int get total => subtotal + shipping - discount;

  void _changed() {
    final value = jsonEncode({
      'cart': _cart.map((e) => e.toJson()).toList(),
      'saved': _saved.toList(),
      'concepts': _savedConcepts.toList(),
      'orders': _orders.map((e) => e.toJson()).toList(),
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'signedIn': signedIn,
      'card': cardLast4,
      'promo': promo,
    });
    _pendingSave = _pendingSave.then((_) async {
      try {
        persistenceError =
            await _preferences.setString('furnite.state.v1', value)
            ? null
            : 'Changes could not be saved on this device.';
      } on Object {
        persistenceError = 'Changes could not be saved on this device.';
      }
    });
    notifyListeners();
  }

  Future<void> flush() => _pendingSave;
  void toggleSaved(String id) {
    if (!_saved.add(id)) {
      _saved.remove(id);
    }
    _changed();
  }

  void toggleConcept(String id) {
    if (!_savedConcepts.add(id)) {
      _savedConcepts.remove(id);
    }
    _changed();
  }

  void add(Product product, {String? color, int quantity = 1}) {
    final chosen = color ?? product.color;
    final index = _cart.indexWhere(
      (e) => e.productId == product.id && e.color == chosen,
    );
    if (index < 0) {
      _cart.add(CartLine(product.id, chosen, quantity.clamp(1, 99)));
    } else {
      _cart[index].quantity = (_cart[index].quantity + quantity).clamp(1, 99);
    }
    _changed();
  }

  void setQuantity(CartLine line, int quantity) {
    if (quantity <= 0) {
      _cart.remove(line);
    } else {
      line.quantity = quantity.clamp(1, 99);
    }
    if (_cart.isEmpty) {
      promo = null;
    }
    _changed();
  }

  void customize(
    CartLine line, {
    required String color,
    required int quantity,
  }) {
    final index = _cart.indexOf(line);
    if (index < 0) {
      return;
    }
    _cart.removeAt(index);
    final matching = _cart.indexWhere(
      (e) => e.productId == line.productId && e.color == color,
    );
    if (matching >= 0) {
      _cart[matching].quantity = (_cart[matching].quantity + quantity).clamp(
        1,
        99,
      );
    } else {
      _cart.insert(
        index,
        CartLine(line.productId, color, quantity.clamp(1, 99)),
      );
    }
    _changed();
  }

  bool applyPromo(String code) {
    final normalized = code.trim().toUpperCase();
    if (normalized != 'FURNITE10' && normalized != 'BLFD30') {
      return false;
    }
    promo = normalized;
    _changed();
    return true;
  }

  void removePromo() {
    promo = null;
    _changed();
  }

  void updateProfile({
    required String fullName,
    required String contactEmail,
    required String contactPhone,
    required String street,
    required String location,
  }) {
    name = fullName.trim();
    email = contactEmail.trim();
    phone = contactPhone.trim();
    address = street.trim();
    city = location.trim();
    _changed();
  }

  void signIn(String contactEmail) {
    email = contactEmail.trim();
    signedIn = true;
    _changed();
  }

  void signOut() {
    signedIn = false;
    _changed();
  }

  void saveCard(String last4) {
    cardLast4 = last4;
    _changed();
  }

  void deleteCard() {
    cardLast4 = null;
    _changed();
  }

  ShopOrder? placeOrder() {
    if (_cart.isEmpty) {
      return null;
    }
    final now = DateTime.now();
    final order = ShopOrder(
      'FN-${now.millisecondsSinceEpoch}',
      now.toIso8601String(),
      _cart.map((e) => CartLine(e.productId, e.color, e.quantity)).toList(),
      total,
    );
    _orders.insert(0, order);
    _cart.clear();
    promo = null;
    _changed();
    return order;
  }
}

class ShopScope extends InheritedNotifier<ShopState> {
  const ShopScope({super.key, required ShopState state, required super.child})
    : super(notifier: state);
  static ShopState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ShopScope>()!.notifier!;
}
