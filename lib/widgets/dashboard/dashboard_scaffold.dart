import 'package:flutter/material.dart';

import '../reusable_button.dart';

enum DashboardNavItem {
  dashboard,
  sales,
  products,
  categories,
  customers,
  suppliers,
  inventory,
  reports,
  expenses,
  settings,
}

/// A premium layout scaffold for all dashboard screens.
/// Features a sleek sidebar with gradient active states, glassmorphism app bar,
/// and smooth responsive behaviors.
class DashboardScaffold extends StatelessWidget {
  const DashboardScaffold({
    super.key,
    required this.title,
    required this.roleLabel,
    required this.userName,
    required this.selectedItem,
    required this.onLogout,
    this.onSalesTap,
    this.onProductsTap,
    this.onCategoriesTap,
    this.onCustomersTap,
    this.onSuppliersTap,
    this.onReportsTap,
    this.onExpensesTap,
    this.onStockTap,
    this.onSettingsTap,
    required this.body,
  });

  final String title;
  final String roleLabel;
  final String userName;
  final DashboardNavItem selectedItem;
  final Future<void> Function() onLogout;
  final VoidCallback? onSalesTap;
  final VoidCallback? onProductsTap;
  final VoidCallback? onCategoriesTap;
  final VoidCallback? onCustomersTap;
  final VoidCallback? onSuppliersTap;
  final VoidCallback? onReportsTap;
  final VoidCallback? onExpensesTap;
  final VoidCallback? onStockTap;
  final VoidCallback? onSettingsTap;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1100;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF), // Sleek bluish-grey background
      appBar: AppBar(
        titleSpacing: 0,
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0.9),
        surfaceTintColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ColorFilter.mode(Colors.white.withOpacity(0.5), BlendMode.srcOver),
            child: Container(color: Colors.transparent),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        leading: isDesktop
            ? null
            : Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
        title: Row(
          children: [
            if (isDesktop) const SizedBox(width: 24),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: Color(0xFF1E293B),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          // Profile section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF2D5BFF),
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Color(0xFF1E293B),
                        height: 1.1,
                      ),
                    ),
                    Text(
                      roleLabel,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: isDesktop
          ? null
          : _DashboardDrawer(
              selectedItem: selectedItem,
              onLogout: onLogout,
              onSalesTap: onSalesTap,
              onProductsTap: onProductsTap,
              onCategoriesTap: onCategoriesTap,
              onCustomersTap: onCustomersTap,
              onSuppliersTap: onSuppliersTap,
              onReportsTap: onReportsTap,
              onExpensesTap: onExpensesTap,
              onStockTap: onStockTap,
              onSettingsTap: onSettingsTap,
            ),
      body: Row(
        children: [
          if (isDesktop)
            SizedBox(
              width: 280,
              child: _DashboardSidebar(
                selectedItem: selectedItem,
                onLogout: onLogout,
                onSalesTap: onSalesTap,
                onProductsTap: onProductsTap,
                onCategoriesTap: onCategoriesTap,
                onCustomersTap: onCustomersTap,
                onSuppliersTap: onSuppliersTap,
                onReportsTap: onReportsTap,
                onExpensesTap: onExpensesTap,
                onStockTap: onStockTap,
                onSettingsTap: onSettingsTap,
              ),
            ),
          Expanded(
            child: ClipRRect(
              borderRadius: isDesktop
                  ? const BorderRadius.only(topLeft: Radius.circular(32))
                  : BorderRadius.zero,
              child: body,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardDrawer extends StatelessWidget {
  const _DashboardDrawer({
    required this.selectedItem,
    required this.onLogout,
    this.onSalesTap,
    this.onProductsTap,
    this.onCategoriesTap,
    this.onCustomersTap,
    this.onSuppliersTap,
    this.onReportsTap,
    this.onExpensesTap,
    this.onStockTap,
    this.onSettingsTap,
  });

  final DashboardNavItem selectedItem;
  final Future<void> Function() onLogout;
  final VoidCallback? onSalesTap;
  final VoidCallback? onProductsTap;
  final VoidCallback? onCategoriesTap;
  final VoidCallback? onCustomersTap;
  final VoidCallback? onSuppliersTap;
  final VoidCallback? onReportsTap;
  final VoidCallback? onExpensesTap;
  final VoidCallback? onStockTap;
  final VoidCallback? onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: _DashboardSidebar(
        selectedItem: selectedItem,
        onLogout: onLogout,
        onSalesTap: onSalesTap,
        onProductsTap: onProductsTap,
        onCategoriesTap: onCategoriesTap,
        onCustomersTap: onCustomersTap,
        onSuppliersTap: onSuppliersTap,
        onReportsTap: onReportsTap,
        onExpensesTap: onExpensesTap,
        onStockTap: onStockTap,
        onSettingsTap: onSettingsTap,
      ),
    );
  }
}

class _DashboardSidebar extends StatelessWidget {
  const _DashboardSidebar({
    required this.selectedItem,
    required this.onLogout,
    this.onSalesTap,
    this.onProductsTap,
    this.onCategoriesTap,
    this.onCustomersTap,
    this.onSuppliersTap,
    this.onReportsTap,
    this.onExpensesTap,
    this.onStockTap,
    this.onSettingsTap,
  });

  final DashboardNavItem selectedItem;
  final Future<void> Function() onLogout;
  final VoidCallback? onSalesTap;
  final VoidCallback? onProductsTap;
  final VoidCallback? onCategoriesTap;
  final VoidCallback? onCustomersTap;
  final VoidCallback? onSuppliersTap;
  final VoidCallback? onReportsTap;
  final VoidCallback? onExpensesTap;
  final VoidCallback? onStockTap;
  final VoidCallback? onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo Area
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2D5BFF), Color(0xFF7C8CFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2D5BFF).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.storefront_rounded,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'POS Pro',
                          style: TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Business System',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Divider(color: Color(0xFFE2E8F0), height: 32),
            ),

            // Navigation Links
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _NavItem(
                      icon: Icons.dashboard_rounded,
                      label: 'Dashboard',
                      selected: selectedItem == DashboardNavItem.dashboard,
                    ),
                    _NavItem(
                      icon: Icons.point_of_sale_rounded,
                      label: 'POS Sales (Billing)',
                      selected: selectedItem == DashboardNavItem.sales,
                      onTap: onSalesTap,
                      isPrimary: true,
                    ),
                    _SectionHeader(title: 'INVENTORY'),
                    _NavItem(
                      icon: Icons.inventory_2_rounded,
                      label: 'Products',
                      selected: selectedItem == DashboardNavItem.products,
                      onTap: onProductsTap,
                    ),
                    _NavItem(
                      icon: Icons.category_rounded,
                      label: 'Categories',
                      selected: selectedItem == DashboardNavItem.categories,
                      onTap: onCategoriesTap,
                    ),
                    _NavItem(
                      icon: Icons.move_to_inbox_rounded,
                      label: 'Stock Manager',
                      selected: selectedItem == DashboardNavItem.inventory,
                      onTap: onStockTap,
                    ),
                    _SectionHeader(title: 'PEOPLE'),
                    _NavItem(
                      icon: Icons.groups_rounded,
                      label: 'Customers',
                      selected: selectedItem == DashboardNavItem.customers,
                      onTap: onCustomersTap,
                    ),
                    _NavItem(
                      icon: Icons.local_shipping_rounded,
                      label: 'Suppliers',
                      selected: selectedItem == DashboardNavItem.suppliers,
                      onTap: onSuppliersTap,
                    ),
                    _SectionHeader(title: 'FINANCE & REPORTS'),
                    _NavItem(
                      icon: Icons.analytics_rounded,
                      label: 'Sales History',
                      selected: selectedItem == DashboardNavItem.reports,
                      onTap: onReportsTap,
                    ),
                    _NavItem(
                      icon: Icons.account_balance_wallet_rounded,
                      label: 'Expenses',
                      selected: selectedItem == DashboardNavItem.expenses,
                      onTap: onExpensesTap,
                    ),
                    _SectionHeader(title: 'SYSTEM'),
                    _NavItem(
                      icon: Icons.settings_rounded,
                      label: 'Settings',
                      selected: selectedItem == DashboardNavItem.settings,
                      onTap: onSettingsTap,
                    ),
                  ],
                ),
              ),
            ),

            // Logout Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: InkWell(
                onTap: () => onLogout(),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, color: Colors.red.shade600, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    this.onTap,
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool isPrimary; // Highlight billing button extra

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    // Colors
    final Color textColor = widget.selected
        ? (widget.isPrimary ? Colors.white : const Color(0xFF2D5BFF))
        : const Color(0xFF475569);

    final Color iconColor = widget.selected
        ? (widget.isPrimary ? Colors.white : const Color(0xFF2D5BFF))
        : const Color(0xFF94A3B8);

    final Color bgColor = widget.selected
        ? (widget.isPrimary ? const Color(0xFF2D5BFF) : const Color(0xFFEFF4FF))
        : _isHovering
            ? const Color(0xFFF8FAFC)
            : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: (widget.selected && widget.isPrimary)
                    ? [
                        BoxShadow(
                          color: const Color(0xFF2D5BFF).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(widget.icon, color: iconColor, size: 22),
                  const SizedBox(width: 14),
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  if (widget.selected)
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: textColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
