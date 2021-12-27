import 'package:badger_group_up/main.dart' as app;
import 'package:badger_group_up/src/system/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';

import '../../database.mocks.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Swipe to register page', (WidgetTester tester) async {
    app.testMode();

    await tester.pumpAndSettle();

    // Confirm default sign in page
    expect(find.text('Sign In!'), findsOneWidget);
    expect(find.text('Register Now!'), findsNothing);

    // Swipe to registration page
    await tester.drag(find.byType(PageView), const Offset(-420, 0));
    await tester.pumpAndSettle();

    // Confirm page switch
    expect(find.text('Sign In!'), findsNothing);
    expect(find.text('Register Now!'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  group('End-to-end', () {
    dynamic _setUp(WidgetTester tester) async {
      app.testMode();

      await tester.pumpAndSettle();

      // Swipe to registration page
      await tester.drag(find.byType(PageView), const Offset(-420, 0));
      await tester.pumpAndSettle();
    }

    testWidgets('Error message', (WidgetTester tester) async {
      await _setUp(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      expect(find.text('Please fill out all fields.'), findsOneWidget);
    });

    testWidgets('Unsuccessful Registration', (WidgetTester tester) async {
      await _setUp(tester);

      var database = MockDatabaseMockito();
      Database.instance = database;

      // Fill TextFields
      List<String> testData = ['test@wisc.edu', 'testFirstName', 'testLastName', 'testPass', 'testPass'];
      for (int i = 0 ; i < find.byType(TextField).evaluate().length ; i++) {
        await tester.enterText(find.byType(TextField).at(i), testData[i]);
        expect((find.byType(TextField).evaluate().elementAt(i).widget as TextField).controller!.text, testData[i]);
      }

      // Mock database call
      when(database.insert('User', any)).thenAnswer((_) async => false);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      // Confirm error message
      expect(find.text('An account with that email already exists.'), findsOneWidget);
    }, skip: true);

    testWidgets('Successful Registration', (WidgetTester tester) async {
      await _setUp(tester);

      var database = MockDatabaseMockito();
      Database.instance = database;

      // Fill TextFields
      List<String> testData = ['test@wisc.edu', 'testFirstName', 'testLastName', 'testPass', 'testPass'];
      for (int i = 0 ; i < find.byType(TextField).evaluate().length ; i++) {
        await tester.enterText(find.byType(TextField).at(i), testData[i]);
        expect((find.byType(TextField).evaluate().elementAt(i).widget as TextField).controller!.text, testData[i]);
      }

      // Mock database call
      when(database.insert('User', any)).thenAnswer((_) async => true);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      // Confirm home screen switch
      expect(find.byType(AppBar), findsOneWidget);
      expect(((find.byType(AppBar).evaluate().elementAt(0).widget as AppBar).title as Text).data, 'Badger Group Up');
    }, skip: true);
  });
}