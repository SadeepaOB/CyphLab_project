import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a single expense item.
/// Kept simple and straightforward with easy-to-read serialization methods.
class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? note;
  final String? userId;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
    this.userId,
  });

  /// Convert an Expense object into a Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
      'note': note ?? '',
      if (userId != null) 'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create an Expense object from a Firestore document snapshot
  factory Expense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Handle date conversion: supports both Firestore Timestamp and fallback String/int
    DateTime parsedDate;
    if (data['date'] is Timestamp) {
      parsedDate = (data['date'] as Timestamp).toDate();
    } else if (data['date'] is String) {
      parsedDate = DateTime.tryParse(data['date']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return Expense(
      id: doc.id,
      title: data['title'] as String? ?? 'Untitled',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      category: data['category'] as String? ?? 'Other',
      date: parsedDate,
      note: (data['note'] as String?)?.isNotEmpty == true ? data['note'] : null,
      userId: data['userId'] as String?,
    );
  }

  /// Create a copy of the expense with updated fields
  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? note,
    String? userId,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      userId: userId ?? this.userId,
    );
  }
}

/// Predefined expense categories with beginner-friendly helper data
class ExpenseCategory {
  static const List<String> categories = [
    'Food & Dining',
    'Shopping',
    'Transportation',
    'Bills & Utilities',
    'Entertainment',
    'Health & Medical',
    'Education',
    'Other',
  ];
}
