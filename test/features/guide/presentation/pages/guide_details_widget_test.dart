import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepalexplorer/features/guide/presentation/pages/guide_details_screen.dart';

Widget _app(Widget home) => MaterialApp(home: home);

void main() {
  testWidgets('Guide details shows user info and about section', (tester) async {
    final guide = {
      '_id': 'g-101',
      'experience': 5,
      'languages': ['English', 'Nepali'],
      'bio': 'Professional trekking guide',
    };
    final user = {
      'fullName': 'Suman Guide',
      'email': 'suman@example.com',
      'phoneNumber': '9801234567',
    };

    await tester.pumpWidget(_app(GuideDetailsScreen(guide: guide, user: user)));

    expect(find.text('Suman Guide'), findsAtLeastNWidgets(1));
    expect(find.text('suman@example.com'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
    expect(find.text('Professional trekking guide'), findsOneWidget);
  });

  testWidgets('Guide details shows fallback values for missing data', (tester) async {
    final guide = {
      '_id': 'g-102',
      'experience': null,
      'languages': null,
      'bio': '',
    };
    final user = {
      'fullName': 'Fallback Guide',
      'email': 'fallback@example.com',
      'phoneNumber': null,
    };

    await tester.pumpWidget(_app(GuideDetailsScreen(guide: guide, user: user)));

    expect(find.text('0 years'), findsOneWidget);
    expect(find.text('Not specified'), findsOneWidget);
    expect(find.text('Not provided'), findsOneWidget);
  });

  testWidgets('Guide details empty form shows validation snackbar', (tester) async {
    final guide = {
      '_id': 'g-103',
      'experience': 2,
      'languages': ['English'],
      'bio': 'Local city guide',
    };
    final user = {
      'fullName': 'Validation Guide',
      'email': 'validation@example.com',
      'phoneNumber': '9811111111',
    };

    await tester.pumpWidget(_app(GuideDetailsScreen(guide: guide, user: user)));

    await tester.scrollUntilVisible(
      find.widgetWithText(ElevatedButton, 'Send Request'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Send Request'));
    await tester.pumpAndSettle();

    expect(find.text('Please fill all required fields'), findsOneWidget);
  });
}
