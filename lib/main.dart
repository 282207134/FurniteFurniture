import 'package:flutter/material.dart';
import 'app.dart';
import 'state/shop_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(FurniteApp(state: await ShopState.load()));
}
