import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/sale_model.dart';
import '../../widgets/sales_history/sale_detail_dialog.dart';

class SalesHistoryList extends StatelessWidget {
  const SalesHistoryList({
    super.key,
    required this.sales,
  });

  final List<SaleModel> sales;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    if (isWide) {
      return _buildDesktopList(context);
    } else {
      return _buildMobileList(context);
    }
  }

  Widget _buildDesktopList(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy hh:mm a');
    final currencyFormat = NumberFormat('#,##0.00', 'en_US');

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: DataTable(
            columnSpacing: 20,
            headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: Color(0xFF475569),
              letterSpacing: 0.5,
            ),
            dataTextStyle: const TextStyle(
              fontSize: 13,
              color: Color(0xFF1E293B),
            ),
            dividerThickness: 1,
            columns: [
              DataColumn(
                label: Row(
                  children: [
                    Icon(Icons.receipt_rounded, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 8),
                    const Text('Invoice #'),
                  ],
                ),
              ),
              DataColumn(
                label: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 8),
                    const Text('Date & Time'),
                  ],
                ),
              ),
              DataColumn(
                label: Row(
                  children: [
                    Icon(Icons.payments_rounded, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 8),
                    const Text('Total'),
                  ],
                ),
              ),
              DataColumn(
                label: Row(
                  children: [
                    Icon(Icons.credit_card_rounded, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 8),
                    const Text('Payment'),
                  ],
                ),
              ),
              DataColumn(
                label: Row(
                  children: [
                    Icon(Icons.shopping_bag_rounded, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 8),
                    const Text('Items'),
                  ],
                ),
              ),
              DataColumn(
                label: Row(
                  children: [
                    Icon(Icons.more_vert_rounded, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 8),
                    const Text('Actions'),
                  ],
                ),
              ),
            ],
            rows: sales.asMap().entries.map((entry) {
              final sale = entry.value;
              final index = entry.key;
              final isEvenRow = index % 2 == 0;

              return DataRow(
                color: MaterialStateProperty.all(
                  isEvenRow ? Colors.white : const Color(0xFFFAFCFE),
                ),
                cells: [
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D5BFF).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        sale.id.substring(0, 8).toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D5BFF),
                        ),
                      ),
                    ),
                  ),
                  DataCell(Text(dateFormat.format(sale.createdAt))),
                  DataCell(
                    Text(
                      'Rs. ${currencyFormat.format(sale.total)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ),
                  DataCell(_PaymentMethodBadge(method: sale.paymentMethod)),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${sale.items.length} item(s)',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                    ),
                  ),
                  DataCell(_buildActionButtons(context, sale)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileList(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy hh:mm a');
    final currencyFormat = NumberFormat('#,##0.00', 'en_US');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sales.length,
      itemBuilder: (context, index) {
        final sale = sales[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invoice #${sale.id.substring(0, 8).toUpperCase()}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateFormat.format(sale.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF34D399)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Rs. ${currencyFormat.format(sale.total)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Payment Method & Items
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _PaymentMethodBadge(method: sale.paymentMethod),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${sale.items.length} item(s)',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Action Buttons
                _buildActionButtons(context, sale),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, SaleModel sale) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        SizedBox(
          height: 36,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.visibility_rounded, size: 16),
            label: const Text('View'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D5BFF),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => SaleDetailDialog(sale: sale),
            ),
          ),
        ),
        SizedBox(
          height: 36,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.print_rounded, size: 16),
            label: const Text('Print'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF64748B),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => _handlePrint(context, sale),
          ),
        ),
        SizedBox(
          height: 36,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Export'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF64748B),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => _handleExport(context, sale),
          ),
        ),
      ],
    );
  }

  Future<void> _handlePrint(BuildContext context, SaleModel sale) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.print_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Opening print dialog...'),
          ],
        ),
        backgroundColor: const Color(0xFF2D5BFF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _handleExport(BuildContext context, SaleModel sale) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.download_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Exporting PDF...'),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ════════════════════════════════════════════
// PAYMENT METHOD BADGE
// ════════════════════════════════════════════
class _PaymentMethodBadge extends StatelessWidget {
  const _PaymentMethodBadge({required this.method});

  final String method;

  Color _getPaymentColor() {
    switch (method.toLowerCase()) {
      case 'cash':
        return const Color(0xFF10B981);
      case 'card':
        return const Color(0xFF3B82F6);
      case 'transfer':
        return const Color(0xFF8B5CF6);
      case 'mobile':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _getPaymentIcon() {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.money_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      case 'transfer':
        return Icons.account_balance_rounded;
      case 'mobile':
        return Icons.phone_android_rounded;
      default:
        return Icons.payments_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getPaymentColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getPaymentIcon(), size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            method.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
