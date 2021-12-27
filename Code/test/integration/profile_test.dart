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

  testWidgets('Navigate to profile screen', (WidgetTester tester) async {
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
    when(database.select('Group')).thenAnswer((_) async => []);
    when(database.select('Session')).thenAnswer((_) async => []);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
    await tester.pump();

    // Confirm home screen switch
    expect(find.byType(AppBar), findsOneWidget);
    expect(((find.byType(AppBar).evaluate().elementAt(0).widget as AppBar).title as Text).data, 'Badger Group Up');

    // Navigate to profile page
    await tester.tap(find.widgetWithIcon(IconButton, Icons.account_box));
    await tester.pumpAndSettle();

    // Confirm profile page switch
    expect((((find.byType(AppBar).evaluate().elementAt(0).widget as AppBar).title as Row).children[1] as Text).data, 'My Profile');
  });

  group('Profile Actions', () {
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

      // Mock database call
      when(database.select('User', conditionals: anyNamed('conditionals'))).thenAnswer((_) async => [['hashedEmail', 'testFirstName', 'testLastName', 'hashPassword', 'creationDate']]);
      when(database.select('Group')).thenAnswer((_) async => []);
      when(database.select('Session')).thenAnswer((_) async => []);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      // Navigate to profile page
      await tester.tap(find.widgetWithIcon(IconButton, Icons.account_box));
      await tester.pumpAndSettle();
    }

    testWidgets('Back Button', (WidgetTester tester) async {
      await _setUp(tester);

      await tester.tap(find.widgetWithIcon(IconButton, Icons.arrow_back));
      await tester.pumpAndSettle();

      // Confirm home screen switch
      expect(find.byType(AppBar), findsOneWidget);
      expect(((find.byType(AppBar).evaluate().elementAt(0).widget as AppBar).title as Text).data, 'Badger Group Up');
    });

    testWidgets('Sign Out', (WidgetTester tester) async {
      await _setUp(tester);

      await tester.tap(find.widgetWithIcon(IconButton, Icons.logout));
      await tester.pumpAndSettle();

      // Confirm User class vars cleared
      expect(User.userEmail, '');
      expect(User.firstName, '');
      expect(User.lastName, '');
      expect(User.creationDate, '');

      // Confirm sign in page switch
      // Check for page title
      expect(find.text('Sign In!'), findsOneWidget);

      // Check for TextFields
      expect(find.byType(TextField), findsNWidgets(2));

      // Check for the sign in button
      expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);

      // Check for forgot password TextButton
      expect(find.byType(TextButton), findsOneWidget);
      expect(find.widgetWithText(TextButton, "Forgot Password?"), findsOneWidget);

      // Check for save credentials
      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.text("Save credentials"), findsOneWidget);
    });

    testWidgets('Delete Account', (WidgetTester tester) async {
      await _setUp(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Delete Account'));
      await tester.pump();

      // Verify alert dialog
      expect(find.text('Do you wish to delete your account?'), findsOneWidget);
      expect(find.text('You will be automatically signed out.'), findsOneWidget);

      // Database mock for delete
      var database = MockDatabaseMockito();
      Database.instance = database;

      when(database.delete(any, any)).thenAnswer((_) async => true);

      await tester.tap(find.widgetWithText(TextButton, "Yes, continue"));
      await tester.pumpAndSettle();

      // Confirm User class vars cleared
      expect(User.userEmail, '');
      expect(User.firstName, '');
      expect(User.lastName, '');
      expect(User.creationDate, '');

      // Confirm sign in page switch
      // Check for page title
      expect(find.text('Sign In!'), findsOneWidget);

      // Check for TextFields
      expect(find.byType(TextField), findsNWidgets(2));

      // Check for the sign in button
      expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);

      // Check for forgot password TextButton
      expect(find.byType(TextButton), findsOneWidget);
      expect(find.widgetWithText(TextButton, "Forgot Password?"), findsOneWidget);

      // Check for save credentials
      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.text("Save credentials"), findsOneWidget);
    });
  });
}