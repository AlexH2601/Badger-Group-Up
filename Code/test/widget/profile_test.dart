import 'package:badger_group_up/src/pages/profile_page/profile_page.dart';
import 'package:badger_group_up/src/system/database.dart';
import 'package:badger_group_up/src/system/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../database.mocks.dart';

void main() {
  var page = const ProfilePage();

  group('Profile Page Widgets', () {
    setUp(() {
      Map<String, String> testUserValues = {
        'email': 'test@wisc.edu',
        'firstName': 'testFirstName',
        'lastName': 'testLastName',
        'creationDate': 'testCreationDate'
      };
      User.loadUserInfo(testUserValues);
      page = const ProfilePage();
    });

    testWidgets('All widgets displayed', (WidgetTester tester) async {
      await tester.pumpWidget(page);

      // Check for AppBar title
      expect(find.byType(AppBar), findsOneWidget);

      // Check for Texts (AppBar, name, email, two buttons)
      expect(find.byType(Text), findsNWidgets(5));

      // Check for Buttons
      expect(find.byType(ElevatedButton), findsNWidgets(2));
    });

    testWidgets('Information displayed', (WidgetTester tester) async {
      await tester.pumpWidget(page);

      // Check for AppBar title
      expect((((find.byType(AppBar).evaluate().elementAt(0).widget as AppBar).title as Row).children[1] as Text).data, 'My Profile');

      // Check for email
      expect(find.text(User.userEmail), findsOneWidget);

      // Check for name
      expect(find.text((User.firstName + ' ' + User.lastName)), findsOneWidget);
    });

    group('Reset Password Button', () {
      testWidgets('Dialog Shows Up', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: page));

        await tester.tap(find.widgetWithText(ElevatedButton, 'Reset Password'));
        await tester.pump();

        // Verify alert dialog
        expect(find.byType(TextButton), findsNWidgets(2));
      });

      testWidgets('Cancel', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: page));

        await tester.tap(find.widgetWithText(ElevatedButton, 'Reset Password'));
        await tester.pump();

        await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
        await tester.pump();

        expect(find.byType(TextButton), findsNothing);
      });

      testWidgets('Invalid Password', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: page));

        await tester.tap(find.widgetWithText(ElevatedButton, 'Reset Password'));
        await tester.pump();

        await tester.tap(find.widgetWithText(TextButton, 'Reset'));
        await tester.pump();

        expect(find.text('Please use a 3+ character password.'), findsOneWidget);
      });

      testWidgets('Server Error', (WidgetTester tester) async {
        var database = MockDatabaseMockito();
        Database.instance = database;

        await tester.pumpWidget(MaterialApp(home: page));

        await tester.tap(find.widgetWithText(ElevatedButton, 'Reset Password'));
        await tester.pump();

        // Enter new password
        await tester.enterText(find.byType(TextField), 'newTestPassword');
        await tester.pump();

        // Verify text on screen
        expect(find.text('newTestPassword'), findsOneWidget);

        when(database.update('User', any, any)).thenAnswer((_) async => false);

        await tester.tap(find.widgetWithText(TextButton, 'Reset'));
        await tester.pumpAndSettle();

        expect(find.text('Error'), findsOneWidget);
        expect(find.text('Sorry, an error has occurred.'), findsOneWidget);
      });

      testWidgets('Successful Change', (WidgetTester tester) async {
        var database = MockDatabaseMockito();
        Database.instance = database;

        await tester.pumpWidget(MaterialApp(home: page));

        await tester.tap(find.widgetWithText(ElevatedButton, 'Reset Password'));
        await tester.pump();

        // Enter new password
        await tester.enterText(find.byType(TextField), 'newTestPassword');
        await tester.pump();

        // Verify text on screen
        expect(find.text('newTestPassword'), findsOneWidget);

        when(database.update('User', any, any)).thenAnswer((_) async => true);

        await tester.tap(find.widgetWithText(TextButton, 'Reset'));
        await tester.pumpAndSettle();

        // Confirm alert dialog
        expect(find.text('Password Changed'), findsOneWidget);
        expect(find.text('New Password: newTestPassword'), findsOneWidget);
      });
    });

    group('Delete Account Button', () {
      testWidgets('Confirm Dialog', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: page));

        await tester.tap(find.widgetWithText(ElevatedButton, 'Delete Account'));
        await tester.pump();

        // Verify alert dialog
        expect(find.text('Do you wish to delete your account?'), findsOneWidget);
        expect(find.text('You will be automatically signed out.'), findsOneWidget);
      });

      testWidgets('Cancel Dialog', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: page));

        await tester.tap(find.widgetWithText(ElevatedButton, 'Delete Account'));
        await tester.pump();

        // Verify alert dialog
        expect(find.text('Do you wish to delete your account?'), findsOneWidget);
        expect(find.text('You will be automatically signed out.'), findsOneWidget);

        await tester.tap(find.widgetWithText(TextButton, 'No'));
        await tester.pump();

        // Verify alert dialog popped
        expect(find.text('Do you wish to delete your account?'), findsNothing);
        expect(find.text('You will be automatically signed out.'), findsNothing);

        // Verify back to profile page
        // Check for AppBar title
        expect((((find.byType(AppBar).evaluate().elementAt(0).widget as AppBar).title as Row).children[1] as Text).data, 'My Profile');

        // Check for email
        expect(find.text(User.userEmail), findsOneWidget);

        // Check for name
        expect(find.text((User.firstName + ' ' + User.lastName)), findsOneWidget);
      });

      testWidgets('Server Error', (WidgetTester tester) async {
        var database = MockDatabaseMockito();
        Database.instance = database;

        await tester.pumpWidget(MaterialApp(home: page));

        await tester.tap(find.widgetWithText(ElevatedButton, 'Delete Account'));
        await tester.pump();

        when(database.delete('User', any)).thenAnswer((_) async => false);

        await tester.tap(find.widgetWithText(TextButton, 'Yes, continue'));
        await tester.pump();

        expect(find.text('Error'), findsOneWidget);
        expect(find.text('Sorry, an error has occurred.'), findsOneWidget);
      });
    });
  });
}