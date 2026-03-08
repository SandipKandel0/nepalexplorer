import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepalexplorer/features/dashboard/presentation/pages/destination/destination_details_screen.dart';

void main() {
  testWidgets('Destination details renders core sections', (tester) async {
    final destination = <String, dynamic>{
      'title': 'Pokhara',
      'location': 'Kaski, Nepal',
      'description': 'Beautiful city with lakes and mountain views.',
      'image': 'assets/images/image1.png',
      'bestTimeToVisit': 'October to December',
    };

    await tester.pumpWidget(
      MaterialApp(
        home: DestinationDetailsScreen(destination: destination),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Nearby Hotels'), findsOneWidget);
    expect(find.text('Hotel Mum\'s Home'), findsOneWidget);
    expect(find.text('Kathmandu Guest House'), findsOneWidget);
    expect(find.text('Hotel Nepal'), findsOneWidget);
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Best Time to Visit'), findsOneWidget);
    expect(find.text('Book a Guide'), findsOneWidget);
  });

  testWidgets('Destination details shows title and location', (tester) async {
    final destination = <String, dynamic>{
      'title': 'Lumbini Garden',
      'location': 'Lumbini',
      'description': 'Birthplace of Buddha and pilgrimage site.',
      'image': 'assets/images/Lumbini.jpeg',
      'bestTimeToVisit': 'September to November',
    };

    await tester.pumpWidget(
      MaterialApp(
        home: DestinationDetailsScreen(destination: destination),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Lumbini Garden'), findsOneWidget);
    expect(find.text('Lumbini'), findsOneWidget);
    expect(find.text('September to November'), findsOneWidget);
  });
}
