import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  AppProvider() {
    _loadSettings();
  }

  bool _initialized = false;
  bool get initialized => _initialized;

  // Settings
  ThemeMode _themeMode = ThemeMode.system;
  String _storeName = 'My POS System';
  String _storeAddress = '123 Main Street, City';
  String _storePhone = '+1 234 567 8900';
  String _currencySymbol = 'Rs.';
  double _taxPercentage = 0.0;
  String? _logoUrl;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  String get storeName => _storeName;
  String get storeAddress => _storeAddress;
  String get storePhone => _storePhone;
  String get currencySymbol => _currencySymbol;
  double get taxPercentage => _taxPercentage;
  String? get logoUrl => _logoUrl;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final isDark = prefs.getBool('isDarkMode');
    if (isDark != null) {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    }

    _storeName = prefs.getString('storeName') ?? _storeName;
    _storeAddress = prefs.getString('storeAddress') ?? _storeAddress;
    _storePhone = prefs.getString('storePhone') ?? _storePhone;
    _currencySymbol = prefs.getString('currencySymbol') ?? _currencySymbol;
    _taxPercentage = prefs.getDouble('taxPercentage') ?? _taxPercentage;
    _logoUrl = prefs.getString('logoUrl');

    _initialized = true;
    notifyListeners();
  }

  Future<void> setThemeMode(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    notifyListeners();
  }

  Future<void> updateStoreSettings({
    required String name,
    required String address,
    required String phone,
    required String currency,
    required double tax,
  }) async {
    _storeName = name;
    _storeAddress = address;
    _storePhone = phone;
    _currencySymbol = currency;
    _taxPercentage = tax;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('storeName', name);
    await prefs.setString('storeAddress', address);
    await prefs.setString('storePhone', phone);
    await prefs.setString('currencySymbol', currency);
    await prefs.setDouble('taxPercentage', tax);
    notifyListeners();
  }

  Future<void> updateLogoUrl(String url) async {
    _logoUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('logoUrl', url);
    notifyListeners();
  }

  void setInitialized(bool v) {
    _initialized = v;
    notifyListeners();
  }
}
