import 'package:flutter/material.dart';

import '../models/app_user_model.dart';

class RoleToggle extends StatelessWidget {
  const RoleToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final UserRole value;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<UserRole>(
      segments: const [
        ButtonSegment(value: UserRole.admin, label: Text('Admin')),
        ButtonSegment(value: UserRole.cashier, label: Text('Cashier')),
      ],
      selected: {value},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
