import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/stock_movement_model.dart';
import '../../providers/stock_provider.dart';

class StockMovementsHistory extends StatelessWidget {
  const StockMovementsHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StockProvider>();
    final movements = provider.movements;

    if (provider.loading && movements.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (movements.isEmpty) {
      return const Center(
        child: Text(
          'No stock movements found.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: movements.length,
      itemBuilder: (context, index) {
        final movement = movements[index];
        final isPositive = movement.quantity >= 0;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isPositive ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              child: Icon(
                isPositive ? Icons.arrow_downward : Icons.arrow_upward,
                color: isPositive ? Colors.green : Colors.orange,
              ),
            ),
            title: Text(
              movement.productName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${movement.type.label} • ${DateFormat('MMM dd, yyyy - hh:mm a').format(movement.createdAt)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                if (movement.reason.isNotEmpty)
                  Text(
                    'Reason: ${movement.reason}',
                    style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
                  ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isPositive ? '+' : ''}${movement.quantity}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isPositive ? Colors.green : Colors.orange,
                  ),
                ),
                Text(
                  'Stock: ${movement.newStock}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
