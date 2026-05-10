import 'package:flutter/material.dart';

import '../../models/app_user_model.dart';
import '../dashboard/pos_dashboard_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PosDashboardScreen(role: UserRole.admin);
  }
}
