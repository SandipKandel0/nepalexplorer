import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepalexplorer/features/dashboard/presentation/pages/dashboard/dashboard_screen.dart';

Widget _app(Widget home) => MaterialApp(home: home);

void main() {
  testWidgets('Dashboard renders categories and section headers', (tester) async {
    await tester.pumpWidget(_app(const DashboardScreen()));

    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Best Destination'), findsOneWidget);
    expect(find.text('Browse Destinations'), findsOneWidget);
    expect(find.text('Guide Details'), findsOneWidget);
  });

  testWidgets('Dashboard search no-match shows empty message', (tester) async {
    await tester.pumpWidget(_app(const DashboardScreen()));

    await tester.enterText(find.byType(TextField), 'no-match-query');
    await tester.pumpAndSettle();

    expect(find.text('No destinations found'), findsOneWidget);
  });
}
