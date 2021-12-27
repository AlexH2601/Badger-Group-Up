import 'package:badger_group_up/main.dart' as app;
import 'package:badger_group_up/src/system/database.dart';
import 'package:badger_group_up/src/system/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';

import '../database.mocks.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Navigate to home screen', (WidgetTester tester) async {
    app.testMode();
    await tester.pumpAndSettle();

    var database = MockDatabaseMockito();
    Database.instance = database;

    // Fill TextFields
    List<String> testData = ['test@wisc.edu', 'testPass'];
    for (int i = 0 ; i < find.byType(TextField).evaluate().length ; i++) {
      await tester.enterText(find.byType(TextField).at(i), testData[i]);
    }

    // Mock database calls
    when(database.select('User', conditionals: anyNamed('conditionals'))).thenAnswer((_) async => [['hashedEmail', 'testFirstName', 'testLastName', 'hashPassword', 'creationDate']]);
    when(database.select(any)).thenAnswer((_) async => []);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
    await tester.pump();

    // Confirm home screen switch
    expect(find.byType(AppBar), findsOneWidget);
    expect(((find.byType(AppBar).evaluate().elementAt(0).widget as AppBar).title as Text).data, 'Badger Group Up');
  });

  group('Home Screen Navigation', () {
    dynamic _setUp(WidgetTester tester) async {
      app.testMode();

      await tester.pumpAndSettle();

      var database = MockDatabaseMockito();
      Database.instance = database;

      // Fill TextFields
      List<String> testData = ['test@wisc.edu', 'testPass'];
      for (int i = 0 ; i < find.byType(TextField).evaluate().length ; i++) {
        await tester.enterText(find.byType(TextField).at(i), testData[i]);
      }

      // Mock database calls
      when(database.select('User', conditionals: anyNamed('conditionals'))).thenAnswer((_) async => [['hashedEmail', 'testFirstName', 'testLastName', 'hashPassword', 'creationDate']]);
      when(database.select(any)).thenAnswer((_) async => []);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();
    }

    testWidgets('Profile Page', (WidgetTester tester) async {
      await _setUp(tester);

      await tester.tap(find.widgetWithIcon(IconButton, Icons.account_box));
      await tester.pumpAndSettle();

      // Confirm profile page switch
      expect((((find.byType(AppBar).evaluate().elementAt(0).widget as AppBar).title as Row).children[1] as Text).data, 'My Profile');
    });

    testWidgets('Beacon History', (WidgetTester tester) async {
      await _setUp(tester);

      await tester.tap(find.widgetWithIcon(IconButton, Icons.history));
      await tester.pumpAndSettle();

      // Confirm beacon history page switch
      expect((((find.byType(AppBar).evaluate().elementAt(0).widget as AppBar).title as Row).children[1] as Text).data, 'Beacon History');
    });

    testWidgets('New Beacon Form', (WidgetTester tester) async {
      await _setUp(tester);

      await tester.tap(find.widgetWithIcon(IconButton, Icons.add));
      await tester.pumpAndSettle();

      // Confirm beacon form page switch
      expect((((find.byType(AppBar).evaluate().elementAt(0).widget as AppBar).title as Row).children[1] as Text).data, 'Create a beacon');
    });

    testWidgets('Refresh', (WidgetTester tester) async {
      await _setUp(tester);

      await tester.tap(find.widgetWithIcon(IconButton, Icons.refresh));
      await tester.pumpAndSettle();
    });
  });

  group('List View Filtering', () {
    dynamic _setUp(WidgetTester tester) async {
      app.testMode();

      await tester.pumpAndSettle();

      var database = MockDatabaseMockito();
      Database.instance = database;

      // Fill TextFields
      List<String> testData = ['test@wisc.edu', 'testPass'];
      for (int i = 0 ; i < find.byType(TextField).evaluate().length ; i++) {
        await tester.enterText(find.byType(TextField).at(i), testData[i]);
      }

      // Mock database calls
      when(database.select('User', conditionals: anyNamed('conditionals'))).thenAnswer((_) async => [['hashedEmail', 'testFirstName', 'testLastName', 'hashPassword', 'creationDate']]);
      when(database.select(any)).thenAnswer((_) async => []);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();

      // Confirm home screen switch
      expect(find.byType(AppBar), findsOneWidget);
      expect(((find.byType(AppBar).evaluate().elementAt(0).widget as AppBar).title as Text).data, 'Badger Group Up');
    }

    testWidgets('Open Filter', (WidgetTester tester) async {
      await _setUp(tester);

      await tester.tap(find.widgetWithIcon(ElevatedButton, Icons.search));
      await tester.pumpAndSettle();

      // Confirm filter popup is open
      expect(find.widgetWithText(ElevatedButton, 'Reset'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Apply'), findsOneWidget);
    });

    testWidgets('Apply Empty Filter', (WidgetTester tester) async {
      await _setUp(tester);

      await tester.tap(find.widgetWithIcon(ElevatedButton, Icons.search));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Apply'));
      await tester.pumpAndSettle();

      // Confirm filter popup is closed
      expect(find.widgetWithText(ElevatedButton, 'Reset'), findsNothing);
      expect(find.widgetWithText(ElevatedButton, 'Apply'), findsNothing);
    });
  });
}