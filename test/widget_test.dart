import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepalexplorer/core/services/favorites_service.dart';
import 'package:nepalexplorer/features/dashboard/presentation/pages/dashboard/dashboard_screen.dart';
import 'package:nepalexplorer/features/dashboard/presentation/pages/destination/destination_details_screen.dart';
import 'package:nepalexplorer/features/dashboard/presentation/pages/favorites/favorites_screen.dart';
import 'package:nepalexplorer/features/guide/presentation/pages/guide_details_screen.dart' as guide_pages;
import 'package:nepalexplorer/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:nepalexplorer/features/splash/presentation/pages/splash_screen.dart';

Widget _testApp(Widget home, {Map<String, WidgetBuilder>? routes}) => MaterialApp(home: home, routes: routes ?? const {});

Widget _appWithSplash() => _testApp(
      const SplashScreen(),
      routes: {
        '/onboarding': _buildFakeOnboarding,
      },
    );

Widget _appWithOnboarding() => _testApp(
      const OnboardingScreen(),
      routes: {
        '/login': _buildFakeLogin,
      },
    );

Widget _buildFakeOnboarding(BuildContext context) => const _FakeOnboarding();

Widget _buildFakeLogin(BuildContext context) => const _FakeLogin();

Widget _appWithDashboard() => _testApp(const DashboardScreen());

class _FakeOnboarding extends StatelessWidget {
  const _FakeOnboarding();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('Fake Onboarding'));
  }
}

class _FakeLogin extends StatelessWidget {
  const _FakeLogin();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('Fake Login'));
  }
}

void main() {
  final favoritesService = FavoritesService();

  setUp(() {
    favoritesService.clearFavorites();
  });

  testWidgets('Splash navigates to onboarding after delay', (tester) async {
    await tester.pumpWidget(_appWithSplash());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Fake Onboarding'), findsOneWidget);
  });

  testWidgets('Onboarding Skip navigates to login', (tester) async {
    await tester.pumpWidget(_appWithOnboarding());
    await tester.tap(find.widgetWithText(TextButton, 'Skip'));
    await tester.pumpAndSettle();
    expect(find.text('Fake Login'), findsOneWidget);
  });

  testWidgets('Guide details renders profile and booking form', (tester) async {
    final guide = {
      '_id': 'g-1',
      'experience': 6,
      'languages': ['English', 'Nepali'],
      'bio': 'Experienced mountain guide',
    };
    final user = {
      'fullName': 'Guide Ram',
      'email': 'guide@example.com',
      'phoneNumber': '9800000000',
    };

    await tester.pumpWidget(
      _testApp(
        guide_pages.GuideDetailsScreen(guide: guide, user: user),
      ),
    );

    expect(find.text('Guide Ram'), findsAtLeastNWidgets(1));
    expect(find.text('guide@example.com'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
    expect(find.text('Send a Request'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Destination Name *'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Send Request'), findsOneWidget);
  });

  testWidgets('Guide details shows validation for empty request form', (tester) async {
    final guide = {
      '_id': 'g-2',
      'experience': 2,
      'languages': ['English'],
      'bio': 'City guide',
    };
    final user = {
      'fullName': 'Guide Sita',
      'email': 'sita@example.com',
      'phoneNumber': '9811111111',
    };

    await tester.pumpWidget(
      _testApp(
        guide_pages.GuideDetailsScreen(guide: guide, user: user),
      ),
    );

    await tester.scrollUntilVisible(
      find.widgetWithText(ElevatedButton, 'Send Request'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Send Request'));
    await tester.pumpAndSettle();

    expect(find.text('Please fill all required fields'), findsOneWidget);
  });

  testWidgets('Guide details shows experience and languages info', (tester) async {
    final guide = {
      '_id': 'g-3',
      'experience': 10,
      'languages': ['English', 'Nepali'],
      'bio': 'Trekking specialist',
    };
    final user = {
      'fullName': 'Guide Hari',
      'email': 'hari@example.com',
      'phoneNumber': '9822222222',
    };

    await tester.pumpWidget(
      _testApp(
        guide_pages.GuideDetailsScreen(guide: guide, user: user),
      ),
    );

    expect(find.text('10 years'), findsOneWidget);
    expect(find.text('English, Nepali'), findsOneWidget);
  });

  testWidgets('Dashboard search shows empty state for unknown query', (tester) async {
    await tester.pumpWidget(_appWithDashboard());
    await tester.enterText(find.byType(TextField), 'zzzzzzz');
    await tester.pumpAndSettle();
    expect(find.text('No destinations found'), findsOneWidget);
  });

  testWidgets('Dashboard clear icon resets search', (tester) async {
    await tester.pumpWidget(_appWithDashboard());
    await tester.enterText(find.byType(TextField), 'pashu');
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.clear), findsOneWidget);
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.clear), findsNothing);
  });

  testWidgets('DestinationCard renders content and tap callback', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: DestinationCard(
            title: 'Test Destination',
            location: 'Test Location',
            rating: '4.8',
            image: 'assets/images/image1.png',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Test Destination'), findsOneWidget);
    expect(find.text('Test Location'), findsOneWidget);
    expect(find.text('4.8'), findsOneWidget);

    await tester.tap(find.text('Test Destination'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('ActivityItem triggers callback on tap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: ActivityItem(
            icon: Icons.favorite,
            label: 'My Favorites',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('My Favorites'));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });

  testWidgets('Destination details renders overview sections', (tester) async {
    final destination = {
      'title': 'Pokhara',
      'location': 'Kaski, Nepal',
      'description': 'Beautiful city with lake views',
      'image': 'assets/images/image1.png',
      'bestTimeToVisit': 'October to December',
    };

    await tester.pumpWidget(
      _testApp(
        DestinationDetailsScreen(destination: destination),
      ),
    );

    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Nearby Places'), findsOneWidget);
    expect(find.text('Nearby Hotels'), findsOneWidget);
    expect(find.text('Book a Guide'), findsOneWidget);
  });

  testWidgets('Favorites screen shows empty state', (tester) async {
    await tester.pumpWidget(_testApp(const FavoritesScreen()));
    expect(find.text('No favorite destinations yet'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Browse Destinations'), findsOneWidget);
  });

  testWidgets('Favorites screen shows a saved destination', (tester) async {
    favoritesService.addFavorite(
      {
        'title': 'Boudhanath Stupa',
        'location': 'Kathmandu',
        'description': 'Ancient Buddhist monument',
        'rating': '4.8',
        'image': 'assets/images/BoudhhaStupa.jpeg',
      },
    );

    await tester.pumpWidget(_testApp(const FavoritesScreen()));
    expect(find.text('Boudhanath Stupa'), findsOneWidget);
    expect(find.text('Details'), findsOneWidget);
  });

  testWidgets('Favorites screen can remove saved destination', (tester) async {
    favoritesService.addFavorite(
      {
        'title': 'Pokhara Lake',
        'location': 'Pokhara',
        'description': 'Lake and mountains',
        'rating': '4.7',
        'image': 'assets/images/image1.png',
      },
    );

    await tester.pumpWidget(_testApp(const FavoritesScreen()));
    expect(find.text('Pokhara Lake'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.favorite).first);
    await tester.pumpAndSettle();

    expect(find.text('Removed from favorites'), findsOneWidget);
  });

}

