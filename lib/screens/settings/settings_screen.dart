import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_user_model.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/dashboard/dashboard_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currencyController = TextEditingController();
  final _taxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appProvider = context.read<AppProvider>();
      _nameController.text = appProvider.storeName;
      _addressController.text = appProvider.storeAddress;
      _phoneController.text = appProvider.storePhone;
      _currencyController.text = appProvider.currencySymbol;
      _taxController.text = appProvider.taxPercentage.toString();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _currencyController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final tax = double.tryParse(_taxController.text) ?? 0.0;
    context.read<AppProvider>().updateStoreSettings(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      currency: _currencyController.text.trim(),
      tax: tax,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved successfully.')),
    );
  }

  Future<void> _pickImage() async {
    // In a real app, you would upload this to Firestore (like in ProductProvider)
    // For now we'll simulate the logo URL or use ProductProvider's pickAndUploadProductImage logic
    final productProvider = context.read<ProductProvider>();
    final url = await productProvider.pickAndUploadProductImage();
    if (url != null && mounted) {
      context.read<AppProvider>().updateLogoUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final appProvider = context.watch<AppProvider>();
    final user = auth.user;

    return DashboardScaffold(
      title: 'Settings',
      roleLabel: user?.role.label ?? 'Admin',
      userName: user?.name ?? user?.email ?? 'User',
      selectedItem: DashboardNavItem.settings,
      onSalesTap: () => Navigator.of(context).pushReplacementNamed('/billing'),
      onProductsTap: () => Navigator.of(context).pushReplacementNamed('/products'),
      onCategoriesTap: () => Navigator.of(context).pushReplacementNamed('/categories'),
      onCustomersTap: () => Navigator.of(context).pushReplacementNamed('/customers'),
      onSuppliersTap: () => Navigator.of(context).pushReplacementNamed('/suppliers'),
      onReportsTap: () => Navigator.of(context).pushReplacementNamed('/reports'),
      onExpensesTap: () => Navigator.of(context).pushReplacementNamed('/expenses'),
      onStockTap: () => Navigator.of(context).pushReplacementNamed('/stock'),
      onLogout: () => auth.logout(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Store Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: appProvider.logoUrl != null ? NetworkImage(appProvider.logoUrl!) : null,
                            child: appProvider.logoUrl == null ? const Icon(Icons.store, size: 40) : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.upload),
                          label: const Text('Change Logo'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Store Name', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Store Address', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Store Phone', border: OutlineInputBorder()),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Financial Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _currencyController,
                            decoration: const InputDecoration(labelText: 'Currency Symbol (e.g. \$, Rs, €)', border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _taxController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Default Tax %', border: OutlineInputBorder()),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Appearance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text('Dark Mode'),
                            subtitle: const Text('Toggle between light and dark theme'),
                            value: appProvider.isDarkMode,
                            onChanged: (val) {
                              appProvider.setThemeMode(val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save),
                label: const Text('Save Settings'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
