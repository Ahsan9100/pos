import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/sales_history_provider.dart';

class SalesHistoryFilters extends StatefulWidget {
  const SalesHistoryFilters({super.key});

  @override
  State<SalesHistoryFilters> createState() => _SalesHistoryFiltersState();
}

class _SalesHistoryFiltersState extends State<SalesHistoryFilters> {
  late TextEditingController _startDateCtrl;
  late TextEditingController _endDateCtrl;

  @override
  void initState() {
    super.initState();
    _startDateCtrl = TextEditingController();
    _endDateCtrl = TextEditingController();
    _updateControllers();
  }

  @override
  void dispose() {
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    super.dispose();
  }

  void _updateControllers() {
    final provider = context.read<SalesHistoryProvider>();
    // Show selected dates if available, otherwise show applied dates
    final startDate = provider.selectedStartDate ?? provider.startDate;
    final endDate = provider.selectedEndDate ?? provider.endDate;
    _startDateCtrl.text = DateFormat('dd/MM/yyyy').format(startDate);
    _endDateCtrl.text = DateFormat('dd/MM/yyyy').format(endDate);
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final provider = context.read<SalesHistoryProvider>();
    // Use selected date if available, otherwise use applied date
    final currentStartDate = provider.selectedStartDate ?? provider.startDate;
    final currentEndDate = provider.selectedEndDate ?? provider.endDate;
    final initialDate = isStartDate ? currentStartDate : currentEndDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2D5BFF),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      if (isStartDate) {
        if (picked.isBefore(currentEndDate)) {
          context.read<SalesHistoryProvider>().setDateRange(picked, currentEndDate);
          _updateControllers();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Start date must be before end date'),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } else {
        if (picked.isAfter(currentStartDate)) {
          context.read<SalesHistoryProvider>().setDateRange(currentStartDate, picked);
          _updateControllers();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('End date must be after start date'),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SalesHistoryProvider>(
      builder: (context, salesProvider, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.filter_list_rounded,
                    color: Colors.grey.shade600,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Date Range Filter',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Spacer(),
                  if (salesProvider.isFiltered)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _DatePickerField(
                      label: 'From Date',
                      controller: _startDateCtrl,
                      onTap: () => _selectDate(context, true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 20,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DatePickerField(
                      label: 'To Date',
                      controller: _endDateCtrl,
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (!salesProvider.isFiltered)
                    Tooltip(
                      message: 'Apply date range filter',
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2D5BFF), Color(0xFF1E40AF)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2D5BFF).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              salesProvider.applyDateFilter();
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.search_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Search',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (salesProvider.isFiltered) ...[
                    const SizedBox(width: 12),
                    Tooltip(
                      message: 'Clear date filter',
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            salesProvider.clearDateFilter();
                            _updateControllers();
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFEF4444).withOpacity(0.3),
                              ),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Color(0xFFEF4444),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════
// DATE PICKER FIELD
// ════════════════════════════════════════════
class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.controller,
    required this.onTap,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF2D5BFF)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    controller.text,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
