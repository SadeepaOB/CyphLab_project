import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/main.dart';

void main() {
  testWidgets('Expense tracker app loads login screen and toggles theme', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseTrackerApp());

    // Verify Welcome Back appears on Login screen
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);

    // Verify dark mode toggle icon button exists
    final themeToggleBtn = find.byTooltip('Toggle Theme');
    expect(themeToggleBtn, findsOneWidget);
    await tester.tap(themeToggleBtn);
    await tester.pumpAndSettle();
  });

  testWidgets('Quick demo login displays dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseTrackerApp());
    await tester.pumpAndSettle();

    // Find and ensure visible the Quick Demo Login button
    final demoBtn = find.text('Quick Demo Login (1-Tap)');
    expect(demoBtn, findsOneWidget);
    await tester.ensureVisible(demoBtn);
    await tester.tap(demoBtn);
    await tester.pumpAndSettle();

    // Now on HomeScreen
    expect(find.text('Expense Tracker'), findsOneWidget);
  });
}
