import 'dart:async';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../models/sale_model.dart';
import '../../services/invoice_generator.dart';

class InvoicePreviewDialog extends StatefulWidget {
  const InvoicePreviewDialog({
    super.key,
    required this.sale,
    required this.invoiceNumber,
    required this.customerName,
    this.businessName = 'POS System',
    this.businessAddress,
    this.businessPhone,
    this.taxId,
  });

  final SaleModel sale;
  final String invoiceNumber;
  final String customerName;
  final String businessName;
  final String? businessAddress;
  final String? businessPhone;
  final String? taxId;

  @override
  State<InvoicePreviewDialog> createState() => _InvoicePreviewDialogState();
}

class _InvoicePreviewDialogState extends State<InvoicePreviewDialog> {
  late Future<pw.Document> _pdfFuture;

  @override
  void initState() {
    super.initState();
    _pdfFuture = InvoiceGenerator.generateInvoice(
      invoiceNumber: widget.invoiceNumber,
      sale: widget.sale,
      customerName: widget.customerName,
      businessName: widget.businessName,
      businessAddress: widget.businessAddress,
      businessPhone: widget.businessPhone,
      taxId: widget.taxId,
    );
  }

  Future<void> _printInvoice() async {
    try {
      final pdf = await _pdfFuture;
      await Printing.layoutPdf(
        onLayout: (_) => pdf.save(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error printing: $e')),
        );
      }
    }
  }

  Future<void> _downloadInvoice() async {
    try {
      final pdf = await _pdfFuture;
      final fileName = 'Invoice_${widget.invoiceNumber}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: fileName,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: FutureBuilder<pw.Document>(
        future: _pdfFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Invoice Preview'),
              ),
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Invoice Preview'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.print),
                  tooltip: 'Print',
                  onPressed: _printInvoice,
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  tooltip: 'Download',
                  onPressed: _downloadInvoice,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            body: PdfPreview(
              build: (_) => snapshot.data!.save(),
              canChangePageFormat: false,
            ),
            bottomNavigationBar: BottomAppBar(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.print),
                      label: const Text('Print'),
                      onPressed: _printInvoice,
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.download),
                      label: const Text('Download'),
                      onPressed: _downloadInvoice,
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
