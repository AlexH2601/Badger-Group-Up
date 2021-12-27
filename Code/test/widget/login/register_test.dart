import 'package:badger_group_up/src/pages/login/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Register Page Widgets', () {
    var page = const Register();

    setUp(() {
      page = const Register();
    });

    testWidgets('All widgets displayed', (WidgetTester tester) async {
      await tester.pumpWidget(page);

      // Check for page title
      expect(find.text('Register Now!'), findsOneWidget);

      // Check for TextFields
      expect(find.byType(TextField), findsNWidgets(5));

      // Check for the register button
      expect(find.widgetWithText(ElevatedButton, 'Register'), findsOneWidget);
    });

    testWidgets('TextFields display change', (WidgetTester tester) async {
      await tester.pumpWidget(page);

      List<String> testData = ['testEmail', 'testFirstName', 'testLastName', 'testPass', 'testPassConfirm'];
      for (int i = 0 ; i < find.byType(TextField).evaluate().length ; i++) {
        await tester.enterText(find.byType(TextField).at(i), testData[i]);
        // Check for text displayed on screen
        expect(find.text(testData[i]), findsOneWidget);
        // Check for controller value
        expect((find.byType(TextField).evaluate().elementAt(i).widget as TextField).controller!.text, testData[i]);
      }
    });
  });

  group('Error text', () {
    var page = const Register();

    setUp(() {
      page = const Register();
    });

    testWidgets('Empty Fields', (WidgetTester tester) async {
      await tester.pumpWidget(page);
    });
  });

  group('Error Text', () {
    var page = const Register();

    setUp(() {
      page = const Register();
    });

    testWidgets('Init', (WidgetTester tester) async {
      await tester.pumpWidget(page);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please fill out all fields.'), findsOneWidget);
    });

    testWidgets('Empty Email', (WidgetTester tester) async {
      await tester.pumpWidget(page);

      List<String> testData = ['testEmail', 'testFirstName', 'testLastName', 'testPass', 'testPassConfirm'];
      for (int i = 1 ; i < find.byType(TextField).evaluate().length ; i++) {
        await tester.enterText(find.byType(TextField).at(i), testData[i]);
        expect((find.byType(TextField).evaluate().elementAt(i).widget as TextField).controller!.text, testData[i]);
      }

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please fill out all fields.'), findsOneWidget);
    });

    testWidgets('Empty First Name', (WidgetTester tester) async {
      await tester.pumpWidget(page);

      List<String> testData = ['testEmail', 'testFirstName', 'testLastName', 'testPass', 'testPassConfirm'];
      for (int i = 0 ; i < find.byType(TextField).evaluate().length ; i++) {
        if (i == 1) continue;
        await tester.enterText(find.byType(TextField).at(i), testData[i]);
        expect((find.byType(TextField).evaluate().elementAt(i).widget as TextField).controller!.text, testData[i]);
      }

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please fill out all fields.'), findsOneWidget);
    });

    testWidgets('Empty Last Name', (WidgetTester tester) async {
      await tester.pumpWidget(page);

      List<String> testData = ['testEmail', 'testFirstName', 'testLastName', 'testPass', 'testPassConfirm'];
      for (int i = 0 ; i < find.byType(TextField).evaluate().length ; i++) {
        if (i == 2) continue;
        await tester.enterText(find.byType(TextField).at(i), testData[i]);
        expect((find.byType(TextField).evaluate().elementAt(i).widget as TextField).controller!.text, testData[i]);
      }

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please fill out all fields.'), findsOneWidget);
    });

    testWidgets('Empty Password', (WidgetTester tester) async {
      await tester.pumpWidget(page);

      List<String> testData = ['testEmail', 'testFirstName', 'testLastName', 'testPass', 'testPassConfirm'];
      for (int i = 0 ; i < find.byType(TextField).evaluate().length ; i++) {
        if (i == 3) continue;
        await tester.enterText(find.byType(TextField).at(i), testData[i]);
        expect((find.byType(TextField).evaluate().elementAt(i).widget as TextField).controller!.text, testData[i]);
      }

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please fill out all fields.'), findsOneWidget);
    });

    testWidgets('Empty Confirm Password', (WidgetTester tester) async {
      await tester.pumpWidget(page);

      List<String> testData = ['testEmail', 'testFirstName', 'testLastName', 'testPass', 'testPassConfirm'];
      for (int i = 0 ; i < find.byType(TextField).evaluate().length ; i++) {
        if (i == 4) continue;
        await tester.enterText(find.byType(TextField).at(i), testData[i]);
        expect((find.byType(TextField).evaluate().elementAt(i).widget as TextField).controller!.text, testData[i]);
      }

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please fill out all fields.'), findsOneWidget);
    });

    testWidgets('Incorrect Email Format', (WidgetTester tester) async {
      await tester.pumpWidget(page);

      List<String> testData = ['testEmail', 'testFirstName', 'testLastName', 'testPass', 'testPassConfirm'];
      for (int i = 0 ; i < find.byType(TextField).evaluate().length ; i++) {
        await tester.enterText(find.byType(TextField).at(i), testData[i]);
        expect((find.byType(TextField).evaluate().elementAt(i).widget as TextField).controller!.text, testData[i]);
      }

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please use your wisc.edu email.'), findsOneWidget);
    });

    testWidgets('Insufficient Password Length', (WidgetTester tester) async {
      await tester.pumpWidget(page);

      List<String> testData = ['test@wisc.edu', 'testFirstName', 'testLastName', 'p', 'testPassConfirm'];
      for (int i = 0 ; i < find.byType(TextField).evaluate().length ; i++) {
        await tester.enterText(find.byType(TextField).at(i), testData[i]);
        expect((find.byType(TextField).evaluate().elementAt(i).widget as TextField).controller!.text, testData[i]);
      }

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please use a 3+ character password.'), findsOneWidget);
    });

    testWidgets('Password Mismatch', (WidgetTester tester) async {
      await tester.pumpWidget(page);

      List<String> testData = ['test@wisc.edu', 'testFirstName', 'testLastName', 'testPass', 'testPassConfirm'];
      for (int i = 0 ; i < find.byType(TextField).evaluate().length ; i++) {
        await tester.enterText(find.byType(TextField).at(i), testData[i]);
        expect((find.byType(TextField).evaluate().elementAt(i).widget as TextField).controller!.text, testData[i]);
      }

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Passwords do not match.'), findsOneWidget);
    });
  });
}