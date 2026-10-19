import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:login_form/app_theme.dart';
import 'package:login_form/home_screen.dart';
import 'package:login_form/login_screen.dart';
import 'package:login_form/main.dart';
import 'package:login_form/models/exercise.dart';

/// The background animations repeat forever, so tests pump fixed durations
/// instead of calling pumpAndSettle.
Future<void> settle(WidgetTester tester, [int ms = 1000]) async {
  await tester.pump();
  for (var elapsed = 0; elapsed < ms; elapsed += 100) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Scrolls the dashboard's main list until [finder] is built and visible.
/// Negative [delta] scrolls back up.
Future<void> scrollDashboard(
  WidgetTester tester,
  Finder finder, {
  double delta = 300,
}) => tester.scrollUntilVisible(
  finder,
  delta,
  scrollable: find.byType(Scrollable).first,
);

void usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

void main() {
  group('calorie math', () {
    test('MET x kg x hours', () {
      expect(caloriesBurned(met: 8, weightKg: 70, minutes: 30), 280);
      expect(caloriesBurned(met: 10, weightKg: 60, minutes: 60), 600);
    });

    test('every exercise has three increasing intensities', () {
      for (final e in exercises) {
        expect(e.mets.length, Intensity.values.length);
        expect(e.hints.length, Intensity.values.length);
        expect(e.mets[0] < e.mets[1] && e.mets[1] < e.mets[2], isTrue);
      }
    });

    test('greeting name comes from the email', () {
      expect(nameFromEmail('jane.doe@mail.com'), 'Jane');
      expect(nameFromEmail('  ALEX99@x.io '), 'Alex');
      expect(nameFromEmail('@x.io'), 'Athlete');
    });
  });

  testWidgets('app opens on the FitBurn login screen', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(const LoginApp());
    await settle(tester);

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('FitBurn'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('empty submit shows validation errors', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(const LoginApp());
    await settle(tester);

    await tester.tap(find.text('Sign in'));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('sign in, calculate, and log a workout', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(const LoginApp());
    await settle(tester);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'jane.doe@mail.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'secret1');
    await tester.tap(find.text('Sign in'));
    await settle(tester, 2500);

    // Dashboard greets the user and opens with sample workouts already
    // logged: yoga 58 kcal + strength 233 kcal = 291.
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Jane'), findsOneWidget);
    expect(find.text('Choose an activity'), findsOneWidget);
    expect(find.text('Last 7 days'), findsOneWidget);
    expect(find.text('291'), findsOneWidget);
    await scrollDashboard(tester, find.text('+58'));
    expect(find.text('No workouts yet'), findsNothing);
    await scrollDashboard(tester, find.text('+233'));
    expect(find.text('+233'), findsOneWidget);
    await scrollDashboard(
      tester,
      find.byKey(const ValueKey('exercise-running')),
      delta: -300,
    );

    // Open the running calculator: 70 kg, 30 min, moderate (MET 9.8).
    await tester.tap(find.byKey(const ValueKey('exercise-running')));
    await settle(tester, 1000);

    expect(find.text('Estimated burn'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('kcal-result'))).data,
      '343',
    );

    // Switching to vigorous raises the estimate (12.3 * 70 * 0.5 = 430.5).
    await tester.scrollUntilVisible(
      find.text('Vigorous'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Vigorous'));
    await settle(tester, 800);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('kcal-result'))).data,
      '431',
    );

    // Log it and land back on the dashboard with the entry shown.
    await tester.tap(find.text("Add to today's log"));
    await settle(tester, 1000);

    expect(find.byType(HomeScreen), findsOneWidget);
    await scrollDashboard(tester, find.text('+431'));
    expect(find.textContaining('30 min · Vigorous'), findsOneWidget);
    await scrollDashboard(tester, find.text('722'), delta: -300); // 291 + 431
  });

  testWidgets('dashboard shows an empty state without workouts', (
    tester,
  ) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: const HomeScreen(userName: 'Sam', initialEntries: []),
      ),
    );
    await settle(tester);

    expect(find.text('Last 7 days'), findsOneWidget);
    await scrollDashboard(tester, find.text('No workouts yet'));
    expect(find.text('No workouts yet'), findsOneWidget);
  });
}
