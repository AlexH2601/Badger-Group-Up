import 'package:badger_group_up/main.dart' as app;
import 'package:badger_group_up/src/system/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';

import '../database.mocks.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Navigate to create session', (WidgetTester tester) async {
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

    await tester.tap(find.widgetWithIcon(IconButton, Icons.add));
    await tester.pumpAndSettle();

    // Confirm switch to create a session page
    expect((((find.byType(AppBar).evaluate().elementAt(0).widget as AppBar).title as Row).children[1] as Text).data, 'Create a beacon');
  });

  group('Page functionality', () {
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

      await tester.tap(find.widgetWithIcon(IconButton, Icons.add));
      await tester.pumpAndSettle();
    }

    testWidgets('Cancel button', (WidgetTester tester) async {
      await _setUp(tester);

      // Confirm not on home screen
      expect((((find.byType(AppBar).evaluate().elementAt(0).widget as AppBar).title as Row).children[1] as Text).data, 'Create a beacon');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Cancel'));
      await tester.pumpAndSettle();

      // Confirm back to home screen
      expect(find.byType(AppBar), findsOneWidget);
      expect(((find.byType(AppBar).evaluate().elementAt(0).widget as AppBar).title as Text).data, 'Badger Group Up');
    });
  });
}