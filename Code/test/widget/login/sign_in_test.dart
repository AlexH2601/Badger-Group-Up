import 'package:badger_group_up/src/pages/login/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Sign In Page Widgets', () {
    var page = const SignIn();

    setUp(() {
      page = const SignIn();
    });

    testWidgets('All widgets displayed', (WidgetTester tester) async {
      await tester.pumpWidget(page);

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

    testWidgets('TextFields display change', (WidgetTester tester) async {
      await tester.pumpWidget(page);

      List<String> testData = ['testEmail', 'testPass'];
      for (int i = 0 ; i < find.byType(TextField).evaluate().length ; i++) {
        await tester.enterText(find.byType(TextField).at(i), testData[i]);
        // Check for text displayed on screen
        expect(find.text(testData[i]), findsOneWidget);
        // Check for controller value
        expect((find.byType(TextField).evaluate().elementAt(i).widget as TextField).controller!.text, testData[i]);
      }
    });
  });

  group('Error Text', () {
    var page = const SignIn();

    setUp(() {
      page = const SignIn();
    });

    testWidgets('Init', (WidgetTester tester) async {
      await tester.pumpWidget(page);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please enter your wisc.edu email.'), findsOneWidget);
    });

    testWidgets('Empty Email', (WidgetTester tester) async {
      await tester.pumpWidget(page);

      List<String> testData = ['testEmail', 'testPass'];
      for (int i = 1 ; i < find.byType(TextField).evaluate().length ; i++) {
        await tester.enterText(find.byType(TextField).at(i), testData[i]);
        expect((find.byType(TextField).evaluate().elementAt(i).widget as TextField).controller!.text, testData[i]);
      }

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please enter your wisc.edu email.'), findsOneWidget);
    });

    testWidgets('Empty Password', (WidgetTester tester) async {
      await tester.pumpWidget(page);

      List<String> testData = ['testEmail', 'testPass'];
      for (int i = 0 ; i < find.byType(TextField).evaluate().length ; i++) {
        if (i == 1) continue;
        await tester.enterText(find.byType(TextField).at(i), testData[i]);
        expect((find.byType(TextField).evaluate().elementAt(i).widget as TextField).controller!.text, testData[i]);
      }

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please enter your password.'), findsOneWidget);
    });

    testWidgets('Incorrect Email Format', (WidgetTester tester) async {
      await tester.pumpWidget(page);

      List<String> testData = ['testEmail', 'testPass'];
      for (int i = 0 ; i < find.byType(TextField).evaluate().length ; i++) {
        await tester.enterText(find.byType(TextField).at(i), testData[i]);
        expect((find.byType(TextField).evaluate().elementAt(i).widget as TextField).controller!.text, testData[i]);
      }

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please sign in with your wisc.edu email.'), findsOneWidget);
    });

    testWidgets('Insufficient Password Length', (WidgetTester tester) async {
      await tester.pumpWidget(page);

      List<String> testData = ['test@wisc.edu', 'p'];
      for (int i = 0 ; i < find.byType(TextField).evaluate().length ; i++) {
        await tester.enterText(find.byType(TextField).at(i), testData[i]);
        expect((find.byType(TextField).evaluate().elementAt(i).widget as TextField).controller!.text, testData[i]);
      }

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please enter the correct 3+ character password.'), findsOneWidget);
    });
  });

  group('Reset Password', () {
    var page = const SignIn();

    setUp(() {
      page = const SignIn();
    });

    group('Initial Alert Dialog', () {
      dynamic _setUp(WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: page));

        await tester.tap(find.byType(TextButton));
        await tester.pump();
      }

      testWidgets('Visible', (WidgetTester tester) async {
        await _setUp(tester);

        expect(find.text('Reset Password'), findsOneWidget);
        expect(find.byType(TextField), findsNWidgets(4));
        expect(find.byType(TextButton), findsNWidgets(3));
        expect(find.widgetWithText(TextButton, "Submit"), findsOneWidget);
        expect(find.widgetWithText(TextButton, "Cancel"), findsOneWidget);
      });

      testWidgets('Cancel', (WidgetTester tester) async {
        await _setUp(tester);

        expect(find.text('Reset Password'), findsOneWidget);
        expect(find.byType(TextField), findsNWidgets(4));
        expect(find.byType(TextButton), findsNWidgets(3));
        expect(find.widgetWithText(TextButton, "Submit"), findsOneWidget);
        expect(find.widgetWithText(TextButton, "Cancel"), findsOneWidget);

        await tester.tap(find.widgetWithText(TextButton, "Cancel"));
        await tester.pump();

        expect(find.text('Reset Password'), findsNothing);
        expect(find.byType(TextField), findsNWidgets(2));
        expect(find.byType(TextButton), findsNWidgets(1));
        expect(find.widgetWithText(TextButton, "Submit"), findsNothing);
        expect(find.widgetWithText(TextButton, "Cancel"), findsNothing);
      });

      group('Errors', () {
        testWidgets('Initial Empty Values', (WidgetTester tester) async {
          await _setUp(tester);

          await tester.tap(find.widgetWithText(TextButton, "Submit"));
          await tester.pump();

          expect(find.text('Error'), findsOneWidget);
          expect(find.text('Please input a valid email address.'), findsOneWidget);
        });

        testWidgets('Invalid Email', (WidgetTester tester) async {
          await _setUp(tester);

          await tester.enterText(find.widgetWithText(TextField, "Enter your email."), 'testEmail');

          expect(find.text('testEmail'), findsNWidgets(2));

          await tester.tap(find.widgetWithText(TextButton, "Submit"));
          await tester.pump();

          expect(find.text('Error'), findsOneWidget);
          expect(find.text('Please input a valid email address.'), findsOneWidget);
        });

        testWidgets('Invalid Password', (WidgetTester tester) async {
          await _setUp(tester);

          await tester.enterText(find.widgetWithText(TextField, "Enter your email."), 'testEmail@wisc.edu');
          expect(find.text('testEmail@wisc.edu'), findsNWidgets(2));

          await tester.enterText(find.widgetWithText(TextField, "Enter your new password."), 'p');
          expect(find.text('p'), findsNWidgets(2));

          await tester.tap(find.widgetWithText(TextButton, "Submit"));
          await tester.pump();

          expect(find.text('Error'), findsOneWidget);
          expect(find.text('Please use a 3+ character password.'), findsOneWidget);
        });
      });
    });
  });
}