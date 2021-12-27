import 'package:badger_group_up/main.dart' as app;
import 'package:badger_group_up/src/system/database.dart';
import 'package:badger_group_up/src/system/email_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../database.mocks.dart';
import 'email_auth.mocks.dart';

@GenerateMocks([EmailAuthentication])
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end', () {
    testWidgets('Error message', (WidgetTester tester) async {
      app.testMode();
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      expect(find.text('Please enter your wisc.edu email.'), findsOneWidget);
    });

    testWidgets('Unsuccessful Login', (WidgetTester tester) async {
      app.testMode();
      await tester.pumpAndSettle();

      var database = MockDatabaseMockito();
      Database.instance = database;

      // Fill TextFields
      List<String> testData = ['test@wisc.edu', 'testPass'];
      for (int i = 0 ; i < find.byType(TextField).evaluate().length ; i++) {
        await tester.enterText(find.byType(TextField).at(i), testData[i]);
        expect((find.byType(TextField).evaluate().elementAt(i).widget as TextField).controller!.text, testData[i]);
      }

      // Mock database call
      when(database.select('User', conditionals: anyNamed('conditionals'))).thenAnswer((_) async => []);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      // Confirm error message
      expect(find.text('Incorrect email or password.'), findsOneWidget);
    });

    testWidgets('Successful Login', (WidgetTester tester) async {
      app.testMode();
      await tester.pumpAndSettle();

      var database = MockDatabaseMockito();
      Database.instance = database;

      // Fill TextFields
      List<String> testData = ['test@wisc.edu', 'testPass'];
      for (int i = 0 ; i < find.byType(TextField).evaluate().length ; i++) {
        await tester.enterText(find.byType(TextField).at(i), testData[i]);
        expect((find.byType(TextField).evaluate().elementAt(i).widget as TextField).controller!.text, testData[i]);
      }

      // Mock database call
      when(database.select('User', conditionals: anyNamed('conditionals'))).thenAnswer((_) async => [['hashedEmail', 'testFirstName', 'testLastName', 'hashPassword', 'creationDate']]);
      when(database.select(any)).thenAnswer((_) async => []);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      // Confirm home screen switch
      expect(find.byType(AppBar), findsOneWidget);
      expect(((find.byType(AppBar).evaluate().elementAt(0).widget as AppBar).title as Text).data, 'Badger Group Up');
    });

    group('Reset Password', () {
      testWidgets('No account found', (WidgetTester tester) async {
        app.testMode();
        await tester.pumpAndSettle();

        var database = MockDatabaseMockito();
        Database.instance = database;

        // Open reset password dialog
        await tester.tap(find.byType(TextButton));
        await tester.pump();

        // Fill TextFields
        await tester.enterText(find.widgetWithText(TextField, "Enter your email."), 'testEmail@wisc.edu');
        expect(find.text('testEmail@wisc.edu'), findsNWidgets(2));

        await tester.enterText(find.widgetWithText(TextField, "Enter your new password."), 'testPass');
        expect(find.text('testPass'), findsNWidgets(2));

        // Mock database call
        when(database.select('User', conditionals: anyNamed('conditionals'))).thenAnswer((_) async => []);

        await tester.tap(find.widgetWithText(TextButton, 'Submit'));
        await tester.pump();

        // Confirm error dialog
        expect(find.text('Error'), findsOneWidget);
        expect(find.text('There is no account with that email.'), findsOneWidget);
      });

      testWidgets('No account found', (WidgetTester tester) async {
        app.testMode();
        await tester.pumpAndSettle();

        var database = MockDatabaseMockito();
        Database.instance = database;

        var emailAuth = MockEmailAuthentication();

        // Open reset password dialog
        await tester.tap(find.byType(TextButton));
        await tester.pump();

        // Fill TextFields
        await tester.enterText(find.widgetWithText(TextField, "Enter your email."), 'anhuang@wisc.edu');
        //expect(find.text('testEmail@wisc.edu'), findsNWidgets(2));

        await tester.enterText(find.widgetWithText(TextField, "Enter your new password."), 'testPass');
        expect(find.text('testPass'), findsNWidgets(2));

        // Mock database call
        when(database.select('User', conditionals: anyNamed('conditionals'))).thenAnswer((_) async => [['hashedEmail', 'testFirstName', 'testLastName', 'hashPassword', 'creationDate']]);
        when(emailAuth.sendAuthEmail(any)).thenAnswer((_) async => false);

        await tester.tap(find.widgetWithText(TextButton, 'Submit'));
        await tester.pumpAndSettle();

        // Confirm error dialog
        expect(find.text('Error'), findsOneWidget);
        expect(find.text('Sorry, a server error occurred.'), findsOneWidget);
      }, skip: true);
    });
  });
}