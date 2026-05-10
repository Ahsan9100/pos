import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../models/sale_model.dart';
import '../../services/invoice_generator.dart';
import '../invoice_preview_dialog.dart';

class SaleDetailDialog extends StatefulWidget {
  const SaleDetailDialog({
    super.key,
    required this.sale,
  });

  final SaleModel sale;

  @override
  State<SaleDetailDialog> createState() => _SaleDetailDialogState();
}

class _SaleDetailDialogState extends State<SaleDetailDialog> {
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy hh:mm a');
    final currencyFormat = NumberFormat('#,##0.00', 'en_US');
    final sale = widget.sale;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Scaffold(
          backgroundColor: const Color(0xFFF0F4FF),
          appBar: AppBar(
            title: Row(
              children: [
                Icon(Icons.receipt_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Invoice Details',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.3),
                    ),
                    Text(
                      '#${sale.id.substring(0, 8).toUpperCase()}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2D5BFF),
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sale Header Info
                Container(
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoBox('Date & Time', dateFormat.format(sale.createdAt), Icons.calendar_today_rounded),
                          const SizedBox(width: 12),
                          _buildInfoBox('Payment', sale.paymentMethod.toUpperCase(), Icons.credit_card_rounded),
                        ],
                      ),
                      if (sale.customerId != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoBox('Customer ID', sale.customerId!, Icons.person_rounded, fullWidth: true),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Items Section
                Text(
                  'Items Purchased',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DataTable(
                    columnSpacing: 12,
                    horizontalMargin: 16,
                    headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
                    headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: Color(0xFF475569),
                    ),
                    dataTextStyle: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1E293B),
                    ),
                    columns: const [
                      DataColumn(label: Text('Product')),
                      DataColumn(label: Text('Qty'), numeric: true),
                      DataColumn(label: Text('Price'), numeric: true),
                      DataColumn(label: Text('Amount'), numeric: true),
                    ],
                    rows: sale.items.map((item) {
                      final quantity = (item['quantity'] as num).toInt();
                      final unitPrice = (item['unitPrice'] as num).toDouble();
                      final subtotal = (item['subtotal'] as num).toDouble();

                      return DataRow(cells: [
                        DataCell(
                          Expanded(
                            child: Text(
                              item['productName'] ?? 'N/A',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        DataCell(Text(quantity.toString())),
                        DataCell(Text('Rs. ${currencyFormat.format(unitPrice)}')),
                        DataCell(
                          Text(
                            'Rs. ${currencyFormat.format(subtotal)}',
                            style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2D5BFF)),
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // Totals Section
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2D5BFF), Color(0xFF7C8CFF)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2D5BFF).withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildTotalRow(
                        'Subtotal:',
                        currencyFormat.format(sale.subtotal),
                        color: Colors.white.withOpacity(0.8),
                      ),
                      if (sale.discount > 0) ...[
                        const SizedBox(height: 10),
                        _buildTotalRow(
                          'Discount:',
                          '-Rs. ${currencyFormat.format(sale.discount)}',
                          color: const Color(0xFFFFCDD2),
                          isDeduction: true,
                        ),
                      ],
                      const SizedBox(height: 10),
                      _buildTotalRow(
                        'Taxable Amount:',
                        currencyFormat.format(sale.subtotal - sale.discount),
                        color: Colors.white.withOpacity(0.8),
                      ),
                      if (sale.tax > 0) ...[
                        const SizedBox(height: 10),
                        _buildTotalRow(
                          'Tax:',
                          '+Rs. ${currencyFormat.format(sale.tax)}',
                          color: const Color(0xFFC8E6C9),
                          isAddition: true,
                        ),
                      ],
                      Divider(color: Colors.white.withOpacity(0.2), height: 20),
                      _buildTotalRow(
                        'TOTAL:',
                        'Rs. ${currencyFormat.format(sale.total)}',
                        color: Colors.white,
                        isBold: true,
                        fontSize: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.print_rounded, size: 18),
                    label: const Text('Print'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D5BFF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _handlePrint(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('Export PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _handleExport(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox(String label, String value, IconData icon, {bool fullWidth = false}) {
    return Expanded(
      flex: fullWidth ? 0 : 1,
      child: SizedBox(
        width: fullWidth ? double.infinity : null,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14, color: const Color(0xFF2D5BFF)),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    String value, {
    required Color color,
    bool isBold = false,
    bool isDeduction = false,
    bool isAddition = false,
    double fontSize = 14,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            fontSize: fontSize,
            color: color,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
            fontSize: fontSize,
            color: color,
          ),
        ),
      ],
    );
  }

  Future<void> _handlePrint(BuildContext context) async {
    try {
      final pdf = await InvoiceGenerator.generateInvoice(
        invoiceNumber: widget.sale.id.substring(0, 8).toUpperCase(),
        sale: widget.sale,
        customerName: 'Customer',
        businessName: 'POS System',
        businessAddress: 'Your Business Address',
        businessPhone: '+92-XXX-XXXXXXX',
        taxId: 'TAX-XXXXXXXXX',
      );

      if (mounted) {
        await Printing.layoutPdf(onLayout: (_) => pdf.save());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error printing: $e')),
        );
      }
    }
  }

  Future<void> _handleExport(BuildContext context) async {
    try {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (_) => InvoicePreviewDialog(
          sale: widget.sale,
          invoiceNumber: widget.sale.id.substring(0, 8).toUpperCase(),
          customerName: 'Customer',
          businessName: 'POS System',
          businessAddress: 'Your Business Address',
          businessPhone: '+92-XXX-XXXXXXX',
          taxId: 'TAX-XXXXXXXXX',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting: $e')),
        );
      }
    }
  }
}
