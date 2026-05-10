import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/billing_provider.dart';

/// Premium billing summary with totals and payment flow.
/// Features gradient total card, animated payment dialog, and processing state.
class BillingSummary extends StatefulWidget {
  const BillingSummary({super.key});

  @override
  State<BillingSummary> createState() => _BillingSummaryState();
}

class _BillingSummaryState extends State<BillingSummary> {
  late TextEditingController _discountCtrl;
  late TextEditingController _taxCtrl;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _discountCtrl = TextEditingController();
    _taxCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _discountCtrl.dispose();
    _taxCtrl.dispose();
    super.dispose();
  }

  Future<void> _completeSale(BuildContext context) async {
    final billing = context.read<BillingProvider>();
    if (billing.cart.isEmpty) return;

    // Show payment dialog
    final paymentMethod = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PremiumPaymentDialog(total: billing.cartTotal),
    );

    if (paymentMethod == null || !mounted) return;

    setState(() => _processing = true);

    try {
      final saleId = await billing.completeSale(paymentMethod);
      _discountCtrl.clear();
      _taxCtrl.clear();

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          builder: (_) => _SuccessDialog(
            saleId: saleId.substring(0, 8).toUpperCase(),
            total: billing.cartTotal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BillingProvider>(
      builder: (context, billing, _) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Discount & Tax Row
              Row(
                children: [
                  Expanded(
                    child: _MiniInput(
                      controller: _discountCtrl,
                      label: 'Discount %',
                      icon: Icons.discount_outlined,
                      onChanged: (v) {
                        billing.setDiscount(double.tryParse(v) ?? 0);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniInput(
                      controller: _taxCtrl,
                      label: 'Tax %',
                      icon: Icons.receipt_long_outlined,
                      onChanged: (v) {
                        billing.setTax(double.tryParse(v) ?? 0);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Summary rows
              _SummaryLine(
                label: 'Subtotal',
                value: 'Rs. ${billing.cartSubtotal.toStringAsFixed(0)}',
              ),
              if (billing.discountPercent > 0)
                _SummaryLine(
                  label: 'Discount (${billing.discountPercent.toStringAsFixed(1)}%)',
                  value: '-Rs. ${billing.discountAmount.toStringAsFixed(0)}',
                  color: const Color(0xFFEF4444),
                ),
              if (billing.taxPercent > 0)
                _SummaryLine(
                  label: 'Tax (${billing.taxPercent.toStringAsFixed(1)}%)',
                  value: '+Rs. ${billing.taxAmount.toStringAsFixed(0)}',
                  color: const Color(0xFFF59E0B),
                ),

              const SizedBox(height: 12),

              // Total card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF334155)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      'Rs. ${billing.cartTotal.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Pay button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: billing.cart.isEmpty || _processing
                      ? null
                      : () => _completeSale(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _processing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.payments_rounded, size: 22),
                            SizedBox(width: 10),
                            Text(
                              'Complete Sale',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════
// MINI INPUT
// ════════════════════════════════════════════
class _MiniInput extends StatelessWidget {
  const _MiniInput({
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════
// SUMMARY LINE
// ════════════════════════════════════════════
class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color ?? const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
// PREMIUM PAYMENT DIALOG
// ════════════════════════════════════════════
class _PremiumPaymentDialog extends StatefulWidget {
  const _PremiumPaymentDialog({required this.total});
  final double total;

  @override
  State<_PremiumPaymentDialog> createState() => _PremiumPaymentDialogState();
}

class _PremiumPaymentDialogState extends State<_PremiumPaymentDialog> {
  String _selected = 'cash';
  late TextEditingController _amountCtrl;

  @override
  void initState() {
    super.initState();
    _amountCtrl =
        TextEditingController(text: widget.total.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(_amountCtrl.text) ?? widget.total;
    final change = amount - widget.total;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 420, maxHeight: MediaQuery.of(context).size.height * 0.9),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2D5BFF), Color(0xFF7C8CFF)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.payments_rounded,
                      color: Colors.white, size: 32),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Complete Payment',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Total: Rs. ${widget.total.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),

                const SizedBox(height: 24),

                // Payment methods
                ...[
                  ('cash', 'Cash', Icons.money_rounded, const Color(0xFF10B981)),
                  ('card', 'Card', Icons.credit_card_rounded, const Color(0xFF3B82F6)),
                  ('transfer', 'Bank Transfer', Icons.account_balance_rounded, const Color(0xFF8B5CF6)),
                  ('mobile', 'Mobile Payment', Icons.phone_android_rounded, const Color(0xFFF59E0B)),
                ].map((method) => _PaymentMethodTile(
                      value: method.$1,
                      label: method.$2,
                      icon: method.$3,
                      color: method.$4,
                      isSelected: _selected == method.$1,
                      onTap: () => setState(() => _selected = method.$1),
                    )),

                // Cash change
                if (_selected == 'cash') ...[
                  const SizedBox(height: 16),
                  _MiniInput(
                    controller: _amountCtrl,
                    label: 'Amount Received',
                    icon: Icons.attach_money_rounded,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: change >= 0
                          ? const Color(0xFFF0FDF4)
                          : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: change >= 0
                            ? const Color(0xFFBBF7D0)
                            : const Color(0xFFFECACA),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Change:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: change >= 0
                                ? const Color(0xFF166534)
                                : const Color(0xFF991B1B),
                          ),
                        ),
                        Text(
                          'Rs. ${change.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: change >= 0
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: (_selected == 'cash' && change < 0)
                            ? null
                            : () => Navigator.pop(context, _selected),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Confirm Payment',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════
// PAYMENT METHOD TILE
// ════════════════════════════════════════════
class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected ? color.withOpacity(0.08) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? color : const Color(0xFFE2E8F0),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isSelected ? color : const Color(0xFF475569),
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Icon(Icons.check_circle_rounded, color: color, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════
// SUCCESS DIALOG
// ════════════════════════════════════════════
class _SuccessDialog extends StatelessWidget {
  const _SuccessDialog({required this.saleId, required this.total});
  final String saleId;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated check
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF34D399)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 44),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Sale Completed!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Invoice #$saleId',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D5BFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
