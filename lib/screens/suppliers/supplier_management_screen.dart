import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/supplier_model.dart';
import '../../providers/supplier_provider.dart';
import '../../widgets/suppliers/supplier_form_dialog.dart';

class SupplierManagementScreen extends StatelessWidget {
  const SupplierManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showDialog(context: context, builder: (_) => const SupplierFormDialog()),
          ),
        ],
      ),
      body: Consumer<SupplierProvider>(
        builder: (context, provider, _) {
          final suppliers = provider.suppliers;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search suppliers...'),
                  onChanged: provider.setQuery,
                ),
              ),
              Expanded(
                child: LayoutBuilder(builder: (context, constraints) {
                  if (constraints.maxWidth > 800) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Company')),
                          DataColumn(label: Text('Phone')),
                          DataColumn(label: Text('Payment Terms')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: suppliers.map((s) => _buildRow(context, s)).toList(),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: suppliers.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final s = suppliers[index];
                      return ListTile(
                        title: Text(s.name),
                        subtitle: Text('${s.companyName ?? 'N/A'} • ${s.phone}'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) async {
                            if (v == 'edit') {
                              showDialog(context: context, builder: (_) => SupplierFormDialog(existing: s));
                            } else if (v == 'delete') {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete supplier?'),
                                  content: const Text('This action cannot be undone.'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                                    ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
                                  ],
                                ),
                              );
                              if (ok == true) await context.read<SupplierProvider>().deleteSupplier(s.id);
                            } else if (v == 'transactions') {
                              final transactions = await context.read<SupplierProvider>().fetchSupplierTransactions(s.id);
                              showDialog(context: context, builder: (_) => _TransactionsDialog(supplier: s, transactions: transactions));
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'transactions', child: Text('Transactions')),
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  DataRow _buildRow(BuildContext context, SupplierModel s) {
    return DataRow(cells: [
      DataCell(Text(s.name)),
      DataCell(Text(s.companyName ?? 'N/A')),
      DataCell(Text(s.phone)),
      DataCell(Text(s.paymentTerms ?? 'N/A')),
      DataCell(Row(children: [
        IconButton(onPressed: () => showDialog(context: context, builder: (_) => SupplierFormDialog(existing: s)), icon: const Icon(Icons.edit)),
        IconButton(onPressed: () async {
          final ok = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Delete supplier?'),
              content: const Text('This action cannot be undone.'),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
              ],
            ),
          );
          if (ok == true) await context.read<SupplierProvider>().deleteSupplier(s.id);
        }, icon: const Icon(Icons.delete)),
        IconButton(onPressed: () async {
          final transactions = await context.read<SupplierProvider>().fetchSupplierTransactions(s.id);
          showDialog(context: context, builder: (_) => _TransactionsDialog(supplier: s, transactions: transactions));
        }, icon: const Icon(Icons.receipt)),
      ])),
    ]);
  }
}

class _TransactionsDialog extends StatelessWidget {
  const _TransactionsDialog({required this.supplier, required this.transactions});

  final SupplierModel supplier;
  final List<Map<String, dynamic>> transactions;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${supplier.name} — Transactions'),
      content: SizedBox(
        width: 600,
        child: transactions.isEmpty
            ? const Text('No transactions found')
            : ListView.separated(
                shrinkWrap: true,
                itemCount: transactions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final t = transactions[i];
                  final created = t['createdAt'];
                  String dateStr;
                  if (created is DateTime) dateStr = created.toString();
                  else if (created is Map && created['_seconds'] != null) dateStr = DateTime.fromMillisecondsSinceEpoch((created['_seconds'] as int) * 1000).toString();
                  else if (created is int) dateStr = DateTime.fromMillisecondsSinceEpoch(created).toString();
                  else dateStr = created?.toString() ?? '';

                  return ListTile(
                    title: Text('Purchase ${t['id'] ?? ''}'),
                    subtitle: Text('Total: ${t['total']} • ${t['status']} • $dateStr'),
                  );
                },
              ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
    );
  }
}
