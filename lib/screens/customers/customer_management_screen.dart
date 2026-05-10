import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/customer_model.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/customers/customer_form_dialog.dart';

class CustomerManagementScreen extends StatelessWidget {
  const CustomerManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showDialog(context: context, builder: (_) => const CustomerFormDialog()),
          ),
        ],
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, provider, _) {
          final customers = provider.customers;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search customers...'),
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
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Phone')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: customers.map((c) => _buildRow(context, c)).toList(),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: customers.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final c = customers[index];
                      return ListTile(
                        title: Text(c.name),
                        subtitle: Text('${c.email} • ${c.phone}'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) async {
                            if (v == 'edit') {
                              showDialog(context: context, builder: (_) => CustomerFormDialog(existing: c));
                            } else if (v == 'delete') {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete customer?'),
                                  content: const Text('This action cannot be undone.'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                                    ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
                                  ],
                                ),
                              );
                              if (ok == true) await context.read<CustomerProvider>().deleteCustomer(c.id);
                            } else if (v == 'history') {
                              final history = await context.read<CustomerProvider>().fetchPurchaseHistory(c.id);
                              showDialog(context: context, builder: (_) => _HistoryDialog(customer: c, history: history));
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'history', child: Text('Purchase History')),
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

  DataRow _buildRow(BuildContext context, CustomerModel c) {
    return DataRow(cells: [
      DataCell(Text(c.name)),
      DataCell(Text(c.email)),
      DataCell(Text(c.phone)),
      DataCell(Row(children: [
        IconButton(onPressed: () => showDialog(context: context, builder: (_) => CustomerFormDialog(existing: c)), icon: const Icon(Icons.edit)),
        IconButton(onPressed: () async {
          final ok = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Delete customer?'),
              content: const Text('This action cannot be undone.'),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
              ],
            ),
          );
          if (ok == true) await context.read<CustomerProvider>().deleteCustomer(c.id);
        }, icon: const Icon(Icons.delete)),
        IconButton(onPressed: () async {
          final history = await context.read<CustomerProvider>().fetchPurchaseHistory(c.id);
          showDialog(context: context, builder: (_) => _HistoryDialog(customer: c, history: history));
        }, icon: const Icon(Icons.history)),
      ])),
    ]);
  }
}

class _HistoryDialog extends StatelessWidget {
  const _HistoryDialog({required this.customer, required this.history});

  final CustomerModel customer;
  final List<Map<String, dynamic>> history;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${customer.name} — Purchases'),
      content: SizedBox(
        width: 600,
        child: history.isEmpty
            ? const Text('No purchases found')
            : ListView.separated(
                shrinkWrap: true,
                itemCount: history.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final h = history[i];
                  final created = h['createdAt'];
                  String dateStr;
                  if (created is DateTime) dateStr = created.toString();
                  else if (created is Map && created['_seconds'] != null) dateStr = DateTime.fromMillisecondsSinceEpoch((created['_seconds'] as int) * 1000).toString();
                  else if (created is int) dateStr = DateTime.fromMillisecondsSinceEpoch(created).toString();
                  else dateStr = created?.toString() ?? '';

                  return ListTile(
                    title: Text('Order ${h['id'] ?? ''}'),
                    subtitle: Text('Total: ${h['total']} • $dateStr'),
                  );
                },
              ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
    );
  }
}
