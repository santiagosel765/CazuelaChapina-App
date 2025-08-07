import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode;

  ThemeNotifier(this._themeMode);

  ThemeMode get themeMode => _themeMode;

  static const _key = 'themeMode';

  static Future<ThemeNotifier> init() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    final mode = ThemeMode.values.firstWhere(
      (m) => m.name == value,
      orElse: () => ThemeMode.system,
    );
    return ThemeNotifier(mode);
  }

  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}
