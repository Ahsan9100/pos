import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

/// Utility class to seed Firestore with dummy data for testing.
/// Call [SeedData.seedAll] once from the app to populate all collections.
class SeedData {
  static final _firestore = FirebaseFirestore.instance;
  static const _uuid = Uuid();

  /// Seeds all collections with 2-3 sample entries each.
  /// Checks if data already exists to avoid duplicates.
  static Future<void> seedAll() async {
    final categoriesExist = (await _firestore.collection('categories').limit(1).get()).docs.isNotEmpty;
    if (categoriesExist) return; // Data already seeded

    await _seedCategories();
    await _seedProducts();
    await _seedCustomers();
    await _seedSuppliers();
    await _seedExpenseCategories();
    await _seedExpenses();
    await _seedSales();
    await _seedStockMovements();
  }

  // ──────────────────────── Categories ────────────────────────
  static Future<void> _seedCategories() async {
    final batch = _firestore.batch();
    final now = Timestamp.now();

    final categories = [
      {'name': 'Electronics', 'description': 'Mobile phones, laptops, accessories'},
      {'name': 'Groceries', 'description': 'Daily use grocery items'},
      {'name': 'Clothing', 'description': 'Men, Women & Kids clothing'},
    ];

    for (final cat in categories) {
      final docRef = _firestore.collection('categories').doc();
      batch.set(docRef, {...cat, 'createdAt': now, 'updatedAt': now});
    }

    await batch.commit();
  }

  // ──────────────────────── Products ────────────────────────
  static Future<void> _seedProducts() async {
    final batch = _firestore.batch();
    final now = Timestamp.now();

    final products = [
      {
        'name': 'Samsung Galaxy A15',
        'category': 'Electronics',
        'barcode': '8801643123456',
        'salePrice': 45000.0,
        'purchasePrice': 38000.0,
        'stockQuantity': 25,
        'lowStockThreshold': 5,
        'imageUrl': '',
        'description': 'Samsung Galaxy A15 128GB',
      },
      {
        'name': 'Wireless Earbuds',
        'category': 'Electronics',
        'barcode': '8801643789012',
        'salePrice': 3500.0,
        'purchasePrice': 2200.0,
        'stockQuantity': 50,
        'lowStockThreshold': 10,
        'imageUrl': '',
        'description': 'Bluetooth 5.0 Wireless Earbuds',
      },
      {
        'name': 'Basmati Rice 5kg',
        'category': 'Groceries',
        'barcode': '5901234567890',
        'salePrice': 1200.0,
        'purchasePrice': 950.0,
        'stockQuantity': 3,
        'lowStockThreshold': 5,
        'imageUrl': '',
        'description': 'Premium Basmati Rice 5kg pack',
      },
      {
        'name': 'Cotton T-Shirt',
        'category': 'Clothing',
        'barcode': '7501054530107',
        'salePrice': 1500.0,
        'purchasePrice': 900.0,
        'stockQuantity': 40,
        'lowStockThreshold': 8,
        'imageUrl': '',
        'description': 'Men Cotton Round Neck T-Shirt',
      },
    ];

    for (final product in products) {
      final docRef = _firestore.collection('products').doc();
      batch.set(docRef, {...product, 'createdAt': now, 'updatedAt': now});
    }

    await batch.commit();
  }

  // ──────────────────────── Customers ────────────────────────
  static Future<void> _seedCustomers() async {
    final batch = _firestore.batch();
    final now = Timestamp.now();

    final customers = [
      {
        'name': 'Ali Raza',
        'email': 'ali.raza@gmail.com',
        'phone': '+92 301 1234567',
        'address': 'House 12, Block F, Johar Town, Lahore',
      },
      {
        'name': 'Sana Khan',
        'email': 'sana.khan@outlook.com',
        'phone': '+92 321 9876543',
        'address': 'Flat 5B, Clifton, Karachi',
      },
      {
        'name': 'Hassan Ahmed',
        'email': 'hassan.ahmed@yahoo.com',
        'phone': '+92 333 5551234',
        'address': 'Street 7, I-8/2, Islamabad',
      },
    ];

    for (final customer in customers) {
      final docRef = _firestore.collection('customers').doc();
      batch.set(docRef, {...customer, 'createdAt': now, 'updatedAt': now});
    }

    await batch.commit();
  }

  // ──────────────────────── Suppliers ────────────────────────
  static Future<void> _seedSuppliers() async {
    final batch = _firestore.batch();
    final now = Timestamp.now();

    final suppliers = [
      {
        'name': 'Usman Traders',
        'email': 'usman.traders@gmail.com',
        'phone': '+92 300 1112233',
        'companyName': 'Usman Electronics Pvt Ltd',
        'address': 'Hall Road, Lahore',
        'paymentTerms': 'Net 30 days',
      },
      {
        'name': 'Karachi Wholesale',
        'email': 'info@karachiwholesale.pk',
        'phone': '+92 311 4445566',
        'companyName': 'Karachi Wholesale Co.',
        'address': 'Saddar, Karachi',
        'paymentTerms': 'Cash on delivery',
      },
    ];

    for (final supplier in suppliers) {
      final docRef = _firestore.collection('suppliers').doc();
      batch.set(docRef, {...supplier, 'createdAt': now, 'updatedAt': now});
    }

    await batch.commit();
  }

  // ──────────────────────── Expense Categories ────────────────────────
  static Future<void> _seedExpenseCategories() async {
    final batch = _firestore.batch();
    final now = Timestamp.now();

    final categories = [
      {'name': 'Rent', 'description': 'Monthly shop rent'},
      {'name': 'Utilities', 'description': 'Electricity, Gas, Internet bills'},
      {'name': 'Salaries', 'description': 'Employee monthly salaries'},
    ];

    for (final cat in categories) {
      final docRef = _firestore.collection('expense_categories').doc();
      batch.set(docRef, {...cat, 'createdAt': now, 'updatedAt': now});
    }

    await batch.commit();
  }

  // ──────────────────────── Expenses ────────────────────────
  static Future<void> _seedExpenses() async {
    final batch = _firestore.batch();
    final now = Timestamp.now();

    final expenses = [
      {
        'categoryId': 'rent_001',
        'categoryName': 'Rent',
        'amount': 50000.0,
        'description': 'Shop rent for May 2026',
        'notes': 'Paid via bank transfer',
      },
      {
        'categoryId': 'utilities_001',
        'categoryName': 'Utilities',
        'amount': 8500.0,
        'description': 'Electricity bill May 2026',
        'notes': null,
      },
      {
        'categoryId': 'salaries_001',
        'categoryName': 'Salaries',
        'amount': 35000.0,
        'description': 'Cashier salary May 2026',
        'notes': 'Paid in cash',
      },
    ];

    for (final expense in expenses) {
      final docRef = _firestore.collection('expenses').doc();
      batch.set(docRef, {...expense, 'createdAt': now, 'updatedAt': now});
    }

    await batch.commit();
  }

  // ──────────────────────── Sales ────────────────────────
  static Future<void> _seedSales() async {
    final batch = _firestore.batch();

    final sales = [
      {
        'customerId': null,
        'items': [
          {'productName': 'Samsung Galaxy A15', 'quantity': 1, 'price': 45000.0, 'total': 45000.0},
          {'productName': 'Wireless Earbuds', 'quantity': 2, 'price': 3500.0, 'total': 7000.0},
        ],
        'subtotal': 52000.0,
        'discount': 2000.0,
        'tax': 0.0,
        'total': 50000.0,
        'paymentMethod': 'cash',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
      },
      {
        'customerId': null,
        'items': [
          {'productName': 'Basmati Rice 5kg', 'quantity': 3, 'price': 1200.0, 'total': 3600.0},
          {'productName': 'Cotton T-Shirt', 'quantity': 2, 'price': 1500.0, 'total': 3000.0},
        ],
        'subtotal': 6600.0,
        'discount': 0.0,
        'tax': 0.0,
        'total': 6600.0,
        'paymentMethod': 'card',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 5))),
      },
      {
        'customerId': null,
        'items': [
          {'productName': 'Wireless Earbuds', 'quantity': 1, 'price': 3500.0, 'total': 3500.0},
        ],
        'subtotal': 3500.0,
        'discount': 500.0,
        'tax': 0.0,
        'total': 3000.0,
        'paymentMethod': 'cash',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
      },
    ];

    for (final sale in sales) {
      final docRef = _firestore.collection('sales').doc();
      batch.set(docRef, sale);
    }

    await batch.commit();
  }

  // ──────────────────────── Stock Movements ────────────────────────
  static Future<void> _seedStockMovements() async {
    final batch = _firestore.batch();

    final movements = [
      {
        'productId': 'seed_product_1',
        'productName': 'Samsung Galaxy A15',
        'type': 'stockIn',
        'quantity': 30,
        'previousStock': 0,
        'newStock': 30,
        'reason': 'Initial stock from supplier',
        'userId': 'admin',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 3))),
      },
      {
        'productId': 'seed_product_2',
        'productName': 'Wireless Earbuds',
        'type': 'stockIn',
        'quantity': 50,
        'previousStock': 0,
        'newStock': 50,
        'reason': 'New shipment from Usman Traders',
        'userId': 'admin',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
      },
      {
        'productId': 'seed_product_1',
        'productName': 'Samsung Galaxy A15',
        'type': 'sale',
        'quantity': -5,
        'previousStock': 30,
        'newStock': 25,
        'reason': 'Sold to walk-in customers',
        'userId': 'admin',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 6))),
      },
    ];

    for (final movement in movements) {
      final docRef = _firestore.collection('stock_movements').doc(_uuid.v4());
      batch.set(docRef, movement);
    }

    await batch.commit();
  }
}
