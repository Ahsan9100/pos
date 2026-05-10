import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/supplier_model.dart';
import '../../providers/supplier_provider.dart';

class SupplierFormDialog extends StatefulWidget {
  const SupplierFormDialog({super.key, this.existing});

  final SupplierModel? existing;

  @override
  State<SupplierFormDialog> createState() => _SupplierFormDialogState();
}

class _SupplierFormDialogState extends State<SupplierFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _companyNameCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _paymentTermsCtrl;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameCtrl = TextEditingController(text: existing?.name ?? '');
    _emailCtrl = TextEditingController(text: existing?.email ?? '');
    _phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    _companyNameCtrl = TextEditingController(text: existing?.companyName ?? '');
    _addressCtrl = TextEditingController(text: existing?.address ?? '');
    _paymentTermsCtrl = TextEditingController(text: existing?.paymentTerms ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _companyNameCtrl.dispose();
    _addressCtrl.dispose();
    _paymentTermsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<SupplierProvider>();
    await provider.saveSupplier(
      existing: widget.existing,
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      companyName: _companyNameCtrl.text.trim().isEmpty ? null : _companyNameCtrl.text.trim(),
      address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      paymentTerms: _paymentTermsCtrl.text.trim().isEmpty ? null : _paymentTermsCtrl.text.trim(),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Add Supplier' : 'Edit Supplier'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Contact Name'),
                validator: (v) => (v ?? '').trim().isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: (v) => (v ?? '').trim().isEmpty ? 'Please enter a phone' : null,
              ),
              TextFormField(
                controller: _companyNameCtrl,
                decoration: const InputDecoration(labelText: 'Company Name (optional)'),
              ),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Address (optional)'),
              ),
              TextFormField(
                controller: _paymentTermsCtrl,
                decoration: const InputDecoration(labelText: 'Payment Terms (optional)'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
