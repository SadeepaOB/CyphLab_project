import 'package:flutter/material.dart';

/// Helper class providing consistent icons and colors for each expense category.
class CategoryHelper {
  static IconData getIcon(String category) {
    switch (category) {
      case 'Food & Dining':
        return Icons.restaurant;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Transportation':
        return Icons.directions_car;
      case 'Bills & Utilities':
        return Icons.receipt_long;
      case 'Entertainment':
        return Icons.movie;
      case 'Health & Medical':
        return Icons.medical_services;
      case 'Education':
        return Icons.school;
      case 'Other':
      default:
        return Icons.category;
    }
  }

  static Color getColor(String category) {
    switch (category) {
      case 'Food & Dining':
        return Colors.orange;
      case 'Shopping':
        return Colors.purple;
      case 'Transportation':
        return Colors.blue;
      case 'Bills & Utilities':
        return Colors.redAccent;
      case 'Entertainment':
        return Colors.pink;
      case 'Health & Medical':
        return Colors.teal;
      case 'Education':
        return Colors.indigo;
      case 'Other':
      default:
        return Colors.blueGrey;
    }
  }
}
