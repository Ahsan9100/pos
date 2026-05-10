import 'package:flutter/material.dart';

import '../../models/category_model.dart';
import '../auth_text_field.dart';

class CategoryFormDialog extends StatefulWidget {
  const CategoryFormDialog({super.key, this.initialCategory});

  final CategoryModel? initialCategory;

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final category = widget.initialCategory;
    _nameController = TextEditingController(text: category?.name ?? '');
    _descriptionController = TextEditingController(text: category?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Text(widget.initialCategory == null ? 'Add Category' : 'Edit Category'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AuthTextField(
                controller: _nameController,
                label: 'Category name',
                icon: Icons.category_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Category name is required';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  prefixIcon: const Icon(Icons.notes_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              CategoryModel(
                id: widget.initialCategory?.id ?? '',
                name: _nameController.text.trim(),
                description: _descriptionController.text.trim(),
                createdAt: widget.initialCategory?.createdAt ?? DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
