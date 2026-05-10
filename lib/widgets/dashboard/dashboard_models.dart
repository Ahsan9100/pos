import 'package:flutter/material.dart';

class DashboardStatModel {
  const DashboardStatModel({
    required this.title,
    required this.value,
    required this.delta,
    required this.icon,
    required this.gradient,
  });

  final String title;
  final String value;
  final String delta;
  final IconData icon;
  final List<Color> gradient;
}

class SalesPoint {
  const SalesPoint({required this.day, required this.value});

  final String day;
  final double value;
}

class RecentSaleModel {
  const RecentSaleModel({
    required this.invoiceNo,
    required this.customer,
    required this.amount,
    required this.timeLabel,
    required this.status,
  });

  final String invoiceNo;
  final String customer;
  final double amount;
  final String timeLabel;
  final String status;
}
