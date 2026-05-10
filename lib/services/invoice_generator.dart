import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

import '../models/sale_model.dart';

class InvoiceGenerator {
  static Future<pw.Document> generateInvoice({
    required String invoiceNumber,
    required SaleModel sale,
    required String customerName,
    required String businessName,
    String? businessAddress,
    String? businessPhone,
    String? taxId,
  }) async {
    final pdf = pw.Document();

    final dateFormat = DateFormat('dd/MM/yyyy hh:mm a');
    final currencyFormat = NumberFormat('#,##0.00', 'en_US');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(width: 2)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      businessName,
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    if (businessAddress != null) pw.Text(businessAddress),
                    if (businessPhone != null) pw.Text('Phone: $businessPhone'),
                    if (taxId != null) pw.Text('Tax ID: $taxId'),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Invoice details
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Invoice #: $invoiceNumber', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Date: ${dateFormat.format(sale.createdAt)}'),
                      pw.Text('Payment: ${sale.paymentMethod.toUpperCase()}'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Bill To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(customerName),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Items table
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(1.5),
                },
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromInt(0xFF2D5BFF),
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Product', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Qty', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Unit Price', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Amount', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                      ),
                    ],
                  ),
                  // Item rows
                  ...sale.items.map((item) {
                    final unitPrice = (item['unitPrice'] as num).toDouble();
                    final quantity = (item['quantity'] as num).toInt();
                    final subtotal = (item['subtotal'] as num).toDouble();

                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(item['productName'] ?? 'N/A'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(quantity.toString(), textAlign: pw.TextAlign.center),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Rs. ${currencyFormat.format(unitPrice)}', textAlign: pw.TextAlign.right),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Rs. ${currencyFormat.format(subtotal)}', textAlign: pw.TextAlign.right),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
              pw.SizedBox(height: 20),

              // Totals section
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.SizedBox(
                  width: 300,
                  child: pw.Column(
                    children: [
                      _buildTotalRow('Subtotal:', 'Rs. ${currencyFormat.format(sale.subtotal)}'),
                      if (sale.discount > 0)
                        _buildTotalRow(
                          'Discount:',
                          '-Rs. ${currencyFormat.format(sale.discount)}',
                          isDeduction: true,
                        ),
                      _buildTotalRow('Taxable Amount:', 'Rs. ${currencyFormat.format(sale.subtotal - sale.discount)}'),
                      if (sale.tax > 0)
                        _buildTotalRow(
                          'Tax (${((sale.tax / (sale.subtotal - sale.discount)) * 100).toStringAsFixed(1)}%):',
                          '+Rs. ${currencyFormat.format(sale.tax)}',
                          isAddition: true,
                        ),
                      pw.Divider(),
                      _buildTotalRow(
                        'TOTAL:',
                        'Rs. ${currencyFormat.format(sale.total)}',
                        isBold: true,
                        fontSize: 14,
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 30),

              // Footer
              pw.Container(
                alignment: pw.Alignment.center,
                padding: const pw.EdgeInsets.symmetric(vertical: 10),
                decoration: pw.BoxDecoration(
                  border: pw.Border(top: pw.BorderSide(width: 1)),
                ),
                child: pw.Column(
                  children: [
                    pw.Text('Thank you for your purchase!', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 5),
                    pw.Text('Please keep this invoice for your records', style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _buildTotalRow(String label, String value, {bool isBold = false, bool isDeduction = false, bool isAddition = false, double fontSize = 12}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: fontSize,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
