import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/firebase_bootstrap.dart';
import 'core/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/app_provider.dart';
import 'providers/category_provider.dart';
import 'providers/product_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/supplier_provider.dart';
import 'providers/billing_provider.dart';
import 'providers/sales_history_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/expense_category_provider.dart';
import 'providers/stock_provider.dart';
import 'screens/auth/auth_gate.dart';
import 'core/app_router.dart';
import 'core/seed_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await FirebaseBootstrap.initialize();
    // Seed dummy data for testing (runs only once if collections are empty)
    await SeedData.seedAll();
  } catch (error) {
    runApp(_FirebaseSetupErrorApp(message: 'Firebase Initialization Error:\n$error'));
    return;
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => SupplierProvider()),
        ChangeNotifierProvider(create: (_) => BillingProvider()),
        ChangeNotifierProvider(create: (_) => SalesHistoryProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseCategoryProvider()),
        ChangeNotifierProvider(create: (_) => StockProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class _FirebaseSetupErrorApp extends StatelessWidget {
  const _FirebaseSetupErrorApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return MaterialApp(
          title: appProvider.storeName,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: appProvider.themeMode,
          debugShowCheckedModeBanner: false,
          home: const AuthGate(),
          onGenerateRoute: AppRouter.generateRoute,
        );
      },
    );
  }
}

