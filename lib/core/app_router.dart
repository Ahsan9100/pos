import 'package:flutter/material.dart';
import '../screens/auth/auth_gate.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/admin_home_screen.dart';
import '../screens/home/cashier_home_screen.dart';
import '../screens/products/product_management_screen.dart';
import '../screens/categories/category_management_screen.dart';
import '../screens/customers/customer_management_screen.dart';
import '../screens/suppliers/supplier_management_screen.dart';
import '../screens/billing/pos_billing_screen.dart';
import '../screens/sales_history/sales_history_screen.dart';
import '../screens/expenses/expense_management_screen.dart';
import '../screens/expenses/expense_report_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/stock/stock_management_screen.dart';

class AppRouter {
  static const String initialRoute = '/';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const AuthGate());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/forgot-password':
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case '/admin-home':
        return MaterialPageRoute(builder: (_) => const AdminHomeScreen());
      case '/cashier-home':
        return MaterialPageRoute(builder: (_) => const CashierHomeScreen());
      case '/billing':
        return MaterialPageRoute(builder: (_) => const PosBillingScreen());
      case '/sales-history':
        return MaterialPageRoute(builder: (_) => const SalesHistoryScreen());
      case '/expenses':
        return MaterialPageRoute(builder: (_) => const ExpenseManagementScreen());
      case '/expense-report':
        return MaterialPageRoute(builder: (_) => const ExpenseReportScreen());
      case '/reports':
        return MaterialPageRoute(builder: (_) => const ReportsScreen());
      case '/stock':
        return MaterialPageRoute(builder: (_) => const StockManagementScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case '/products':
        return MaterialPageRoute(builder: (_) => const ProductManagementScreen());
      case '/customers':
        return MaterialPageRoute(builder: (_) => const CustomerManagementScreen());
      case '/suppliers':
        return MaterialPageRoute(builder: (_) => const SupplierManagementScreen());
      case '/categories':
        return MaterialPageRoute(builder: (_) => const CategoryManagementScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
