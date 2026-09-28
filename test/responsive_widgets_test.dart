import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenbin/models/pickup_model.dart';
import 'package:greenbin/theme/app_theme.dart';
import 'package:greenbin/widgets/widgets.dart';

void main() {
  Widget buildTestableWidget(Widget child, {Size size = const Size(320, 640)}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: size.width,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('PrimaryButton renders without overflow on narrow 320px screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestableWidget(
        PrimaryButton(
          text: 'Schedule Recyclable Waste Pickup Now',
          icon: Icons.calendar_today_rounded,
          onPressed: () {},
        ),
        size: const Size(320, 480),
      ),
    );
    expect(find.byType(PrimaryButton), findsOneWidget);
  });

  testWidgets('PickupCard renders without overflow on narrow 320px screen',
      (WidgetTester tester) async {
    final demoPickup = PickupModel(
      id: 'demo-pickup',
      userId: 'user-123',
      residentName: 'Community Resident',
      residentPhone: '+1 234 567 8900',
      category: 'Paper & Cardboard Recyclables',
      subCategories: ['Flattened Cardboard Boxes', 'Clean Office Paper'],
      pickupDate: DateTime.now().add(const Duration(days: 2)),
      timeSlot: '09:00 AM - 12:00 PM Window',
      street: 'Flat 402, Green Valley Apartments, Oak Avenue Road',
      city: 'Springfield Community',
      status: PickupStatus.inTransit,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await tester.pumpWidget(
      buildTestableWidget(
        PickupCard(pickup: demoPickup),
        size: const Size(320, 480),
      ),
    );
    expect(find.byType(PickupCard), findsOneWidget);
    expect(find.text('In Transit'), findsOneWidget);
  });

  testWidgets('CategoryCard renders without overflow in tight container',
      (WidgetTester tester) async {
    final cat = WasteCategoryItem.defaultCategories.first;

    await tester.pumpWidget(
      buildTestableWidget(
        SizedBox(
          width: 140,
          height: 150,
          child: CategoryCard(category: cat, isCompact: true, isSelected: true),
        ),
        size: const Size(320, 480),
      ),
    );
    expect(find.byType(CategoryCard), findsOneWidget);
    expect(find.text('Plastic'), findsOneWidget);
  });

  testWidgets('StatusChip renders all 5 statuses accurately',
      (WidgetTester tester) async {
    for (final status in PickupStatus.values) {
      await tester.pumpWidget(
        buildTestableWidget(
          StatusChip(status: status),
        ),
      );
      expect(find.text(status.displayName), findsOneWidget);
    }
  });

  testWidgets('SectionHeader, LoadingState, EmptyState, and ErrorState render cleanly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestableWidget(
        const SingleChildScrollView(
          child: Column(
            children: [
              SectionHeader(
                title: 'Recycling Guidelines for Residents',
                subtitle: 'Learn how to sort plastics, glass, metals, and cardboard properly',
                actionText: 'View All Guides',
              ),
              LoadingState(message: 'Syncing with Firestore...'),
              EmptyState(
                title: 'No Pickups Found',
                message: 'You have not scheduled any pickups yet.',
                actionText: 'Schedule',
              ),
              ErrorState(
                message: 'Failed to connect to database.',
                retryText: 'Retry',
              ),
            ],
          ),
        ),
        size: const Size(360, 1000),
      ),
    );
    expect(find.byType(SectionHeader), findsOneWidget);
    expect(find.byType(LoadingState), findsOneWidget);
    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.byType(ErrorState), findsOneWidget);
  });

  testWidgets('AdaptiveNavigationScaffold switches to NavigationBar on mobile',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: AdaptiveNavigationScaffold(
          currentIndex: 0,
          onDestinationSelected: (_) {},
          destinations: const [
            AppNavDestination(icon: Icons.home, label: 'Home'),
            AppNavDestination(icon: Icons.person, label: 'Profile'),
          ],
          body: const Text('Body Content'),
        ),
      ),
    );

    // On mobile phone portrait viewport, NavigationBar is present
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });
}
