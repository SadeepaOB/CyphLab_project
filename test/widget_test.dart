import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/main.dart';

void main() {
  testWidgets('Expense tracker app loads properly', (WidgetTester tester) async {
    // Build the ExpenseTrackerApp and trigger a frame.
    await tester.pumpWidget(const ExpenseTrackerApp());

    // Verify that the title appears
    expect(find.text('Expense Tracker'), findsOneWidget);
  });
}
