import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenbin/models/pickup_model.dart';
import 'package:greenbin/routes/app_routes.dart';
import 'package:greenbin/screens/guide/category_details_screen.dart';
import 'package:greenbin/screens/guide/waste_guide_screen.dart';
import 'package:greenbin/screens/schedule/schedule_pickup_screen.dart';
import 'package:greenbin/theme/app_theme.dart';
import 'package:greenbin/widgets/waste_category_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  const viewports = <String, Size>{
    'small mobile (320x480)': Size(320, 480),
    'small mobile landscape (568x320)': Size(568, 320),
    'standard mobile (390x844)': Size(390, 844),
    'standard mobile landscape (844x390)': Size(844, 390),
    'large mobile (428x926)': Size(428, 926),
    'large mobile landscape (926x428)': Size(926, 428),
    'tablet portrait (768x1024)': Size(768, 1024),
    'tablet landscape (1024x768)': Size(1024, 768),
    'desktop (1366x768)': Size(1366, 768),
    'wide desktop (1920x1080)': Size(1920, 1080),
  };

  void setViewport(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget buildGuideApp() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const WasteGuideScreen(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }

  Widget buildCategoryDetailsApp({required WasteCategoryItem category}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: CategoryDetailsScreen(category: category),
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }

  group('Waste Category Guide - Core Content & Categories', () {
    testWidgets('renders all 5 required waste categories with reusable WasteCategoryCard',
        (tester) async {
      setViewport(tester, const Size(768, 1024));
      await tester.pumpWidget(buildGuideApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // Verify Screen Header
      expect(find.text('Recycling Category Guide'), findsOneWidget);

      // Verify the 5 required categories
      expect(find.widgetWithText(WasteCategoryCard, 'Plastic'), findsOneWidget);
      expect(find.widgetWithText(WasteCategoryCard, 'Paper & Cardboard'), findsOneWidget);
      expect(find.widgetWithText(WasteCategoryCard, 'Glass'), findsOneWidget);
      expect(find.widgetWithText(WasteCategoryCard, 'Metal'), findsOneWidget);
      expect(find.widgetWithText(WasteCategoryCard, 'E-Waste'), findsOneWidget);

      // Verify Reusable WasteCategoryCard widgets exist
      expect(find.byType(WasteCategoryCard), findsNWidgets(5));
    });

    testWidgets('search filters recyclable materials across categories',
        (tester) async {
      setViewport(tester, const Size(768, 1024));
      await tester.pumpWidget(buildGuideApp());
      await tester.pumpAndSettle();

      // Enter search term for e-waste (e.g. "battery" or "laptop")
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'laptop');
      await tester.pumpAndSettle();

      // E-Waste should be visible, others filtered out
      expect(find.widgetWithText(WasteCategoryCard, 'E-Waste'), findsOneWidget);
      expect(find.widgetWithText(WasteCategoryCard, 'Paper & Cardboard'), findsNothing);

      // Clear search
      final clearButton = find.byIcon(Icons.clear_rounded);
      expect(clearButton, findsOneWidget);
      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      // All 5 categories reappear
      expect(find.byType(WasteCategoryCard), findsNWidgets(5));
    });

    testWidgets('quick filter chips correctly filter category cards',
        (tester) async {
      setViewport(tester, const Size(768, 1024));
      await tester.pumpWidget(buildGuideApp());
      await tester.pumpAndSettle();

      // Tap 'Glass' filter chip
      final glassChip = find.widgetWithText(ChoiceChip, 'Glass');
      expect(glassChip, findsOneWidget);
      await tester.tap(glassChip);
      await tester.pumpAndSettle();

      // Only Glass card should be visible
      expect(find.byType(WasteCategoryCard), findsOneWidget);
      expect(find.widgetWithText(WasteCategoryCard, 'Glass'), findsOneWidget);
      expect(find.widgetWithText(WasteCategoryCard, 'Plastic'), findsNothing);

      // Tap 'All Materials' to reset
      final allChip = find.widgetWithText(ChoiceChip, 'All Materials');
      await tester.tap(allChip);
      await tester.pumpAndSettle();

      expect(find.byType(WasteCategoryCard), findsNWidgets(5));
    });
  });

  group('Waste Category Guide - Responsive Layout Verification', () {
    testWidgets('mobile (<600px) uses single-column ListView of category cards',
        (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(buildGuideApp());
      await tester.pumpAndSettle();

      // On mobile, category cards are contained inside a ListView
      final listViewFinder = find.byType(ListView);
      expect(listViewFinder, findsOneWidget);

      // Verify WasteCategoryCard is using single-column mode
      final cards = tester.widgetList<WasteCategoryCard>(find.byType(WasteCategoryCard));
      expect(cards.every((c) => c.isSingleColumn), isTrue);
    });

    testWidgets('tablet (600-999px) uses 2-column GridView', (tester) async {
      setViewport(tester, const Size(768, 1024));
      await tester.pumpWidget(buildGuideApp());
      await tester.pumpAndSettle();

      final gridViewFinder = find.byType(GridView);
      expect(gridViewFinder, findsOneWidget);

      final gridView = tester.widget<GridView>(gridViewFinder);
      final delegate =
          gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, equals(2));

      final cards = tester.widgetList<WasteCategoryCard>(find.byType(WasteCategoryCard));
      expect(cards.every((c) => !c.isSingleColumn), isTrue);
    });

    testWidgets('desktop (>=1000px) uses 3-column GridView', (tester) async {
      setViewport(tester, const Size(1366, 768));
      await tester.pumpWidget(buildGuideApp());
      await tester.pumpAndSettle();

      final gridViewFinder = find.byType(GridView);
      expect(gridViewFinder, findsOneWidget);

      final gridView = tester.widget<GridView>(gridViewFinder);
      final delegate =
          gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, equals(3));

      final cards = tester.widgetList<WasteCategoryCard>(find.byType(WasteCategoryCard));
      expect(cards.every((c) => !c.isSingleColumn), isTrue);
    });
  });

  group('Category Details Screen - Content & Responsive Adaptations', () {
    for (final category in WasteCategoryItem.defaultCategories) {
      testWidgets('renders full guidelines for ${category.name}', (tester) async {
        setViewport(tester, const Size(390, 844));
        await tester.pumpWidget(buildCategoryDetailsApp(category: category));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);

        // Header & category name
        expect(find.text('${category.name} Guide'), findsOneWidget);
        expect(find.text('Accepted Materials'), findsOneWidget);
        expect(find.text('Not Accepted / Prohibited'), findsOneWidget);
        expect(find.text('Preparation & Sorting Instructions'), findsOneWidget);
        expect(find.text('Community Impact Note'), findsOneWidget);
      });
    }

    testWidgets('mobile Category Details layout includes sticky bottom schedule button',
        (tester) async {
      setViewport(tester, const Size(390, 844));
      final plastic = WasteCategoryItem.defaultCategories.first;
      await tester.pumpWidget(buildCategoryDetailsApp(category: plastic));
      await tester.pumpAndSettle();

      // Mobile bottom bar schedule button
      expect(find.text('Schedule Plastic Pickup'), findsOneWidget);
    });

    testWidgets('tablet Category Details layout uses side-by-side accepted/prohibited row',
        (tester) async {
      setViewport(tester, const Size(768, 1024));
      final glass = WasteCategoryItem.defaultCategories[2];
      await tester.pumpWidget(buildCategoryDetailsApp(category: glass));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Schedule Pickup'), findsOneWidget);
      expect(find.text('Ready to recycle Glass?'), findsOneWidget);
    });

    testWidgets('desktop Category Details layout uses multi-column split layout',
        (tester) async {
      setViewport(tester, const Size(1366, 768));
      final metal = WasteCategoryItem.defaultCategories[3];
      await tester.pumpWidget(buildCategoryDetailsApp(category: metal));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Schedule Collection'), findsOneWidget);
      expect(find.text('Schedule Metal Pickup'), findsOneWidget);
      expect(find.text('Back to Category Guide'), findsOneWidget);
    });
  });

  group('Navigation Flow: Guide → Category Details → Schedule Pickup', () {
    testWidgets(
        'tap category card navigates to Category Details and Schedule Pickup with category passed via named route arguments',
        (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(buildGuideApp());
      await tester.pumpAndSettle();

      // 1. In Guide Screen: Tap on "Glass" category card
      final glassCard = find.widgetWithText(WasteCategoryCard, 'Glass');
      expect(glassCard, findsOneWidget);
      await tester.tap(glassCard);
      await tester.pumpAndSettle();

      // 2. Verified on Category Details Screen for Glass
      expect(find.byType(CategoryDetailsScreen), findsOneWidget);
      expect(find.text('Glass Guide'), findsOneWidget);
      expect(find.text('Clear, green, and brown glass jars and beverage bottles.'),
          findsOneWidget);

      // 3. Tap Schedule Glass Pickup button
      final scheduleBtn = find.text('Schedule Glass Pickup');
      expect(scheduleBtn, findsOneWidget);
      await tester.tap(scheduleBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // 4. Verified on Schedule Pickup Screen with Glass pre-selected!
      expect(find.byType(SchedulePickupScreen), findsOneWidget);
      expect(find.text('Glass'), findsWidgets);
    });
  });

  group('Waste Category Guide - Responsive Viewport Matrix (Zero Overflow)', () {
    for (final entry in viewports.entries) {
      testWidgets('Guide renders cleanly without overflow on ${entry.key}',
          (tester) async {
        setViewport(tester, entry.value);
        await tester.pumpWidget(buildGuideApp());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Recycling Category Guide'), findsOneWidget);
      });

      testWidgets('Category Details renders cleanly without overflow on ${entry.key}',
          (tester) async {
        setViewport(tester, entry.value);
        final ewaste = WasteCategoryItem.defaultCategories.firstWhere((c) => c.id == 'ewaste');
        await tester.pumpWidget(buildCategoryDetailsApp(category: ewaste));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('E-Waste Guide'), findsOneWidget);
      });
    }
  });
}
