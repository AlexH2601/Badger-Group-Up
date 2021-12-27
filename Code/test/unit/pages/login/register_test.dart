import 'package:badger_group_up/src/pages/login/register_page.dart';
import 'package:badger_group_up/src/system/database.dart';
import 'package:badger_group_up/src/system/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../../../database.mocks.dart';

class RegisterDBStub extends Register {
  const RegisterDBStub({Key? key}) : super(key: key);

  @override
  RegisterDBStubState createState() => RegisterDBStubState();
}

class RegisterDBStubState extends RegisterState<RegisterDBStub> {
  @override
  dynamic registerDB(String creationDate) async {}
}

void main() {
  group('verifyUserInfo - Empty', () {
    var widget = const Register();
    var element = widget.createElement();
    var state = element.state as RegisterState;

    setUp(() {
      widget = const Register();
      element = widget.createElement();
      state = element.state as RegisterState;
    });

    test('Init', () {
      expect(state.verifyUserInfo(), false);
    });

    test('Email Empty', () {
      state.registerTextControllers['firstName']!.text = 'testFirstName';
      state.registerTextControllers['lastName']!.text = 'testLastName';
      state.registerTextControllers['pass']!.text = 'testPass';
      state.registerTextControllers['passConfirm']!.text = 'testPass';
      expect(state.verifyUserInfo(), false);
    });

    test('First Name Empty', () {
      state.registerTextControllers['email']!.text = 'testEmail';
      state.registerTextControllers['lastName']!.text = 'testLastName';
      state.registerTextControllers['pass']!.text = 'testPass';
      state.registerTextControllers['passConfirm']!.text = 'testPass';
      expect(state.verifyUserInfo(), false);
    });

    test('Last Name Empty', () {
      state.registerTextControllers['email']!.text = 'testEmail';
      state.registerTextControllers['firstName']!.text = 'testFirstName';
      state.registerTextControllers['pass']!.text = 'testPass';
      state.registerTextControllers['passConfirm']!.text = 'testPass';
      expect(state.verifyUserInfo(), false);
    });

    test('Password Empty', () {
      state.registerTextControllers['email']!.text = 'testEmail';
      state.registerTextControllers['firstName']!.text = 'testFirstName';
      state.registerTextControllers['lastName']!.text = 'testLastName';
      state.registerTextControllers['passConfirm']!.text = 'testPass';
      expect(state.verifyUserInfo(), false);
    });

    test('Password Confirm Empty', () {
      state.registerTextControllers['email']!.text = 'testEmail';
      state.registerTextControllers['firstName']!.text = 'testFirstName';
      state.registerTextControllers['lastName']!.text = 'testLastName';
      state.registerTextControllers['pass']!.text = 'testPass';
      expect(state.verifyUserInfo(), false);
    });
  });

  group('verifyUserInfo - Email', () {
    var widget = const Register();
    var element = widget.createElement();
    var state = element.state as RegisterState;

    setUp(() {
      widget = const Register();
      element = widget.createElement();
      state = element.state as RegisterState;
      state.registerTextControllers['email']!.text = 'testEmail';
      state.registerTextControllers['firstName']!.text = 'testFirstName';
      state.registerTextControllers['lastName']!.text = 'testLastName';
      state.registerTextControllers['pass']!.text = 'testPass';
      state.registerTextControllers['passConfirm']!.text = 'testPass';
    });

    test('Incorrect Format', () {
      state.registerTextControllers['email']!.text = 'testEmail';
      expect(state.verifyUserInfo(), false);
    });
  });

  group('Password', () {
    var widget = const Register();
    var element = widget.createElement();
    var state = element.state as RegisterState;

    setUp(() {
      widget = const Register();
      element = widget.createElement();
      state = element.state as RegisterState;
      state.registerTextControllers['email']!.text = 'test@wisc.edu';
      state.registerTextControllers['firstName']!.text = 'testFirstName';
      state.registerTextControllers['lastName']!.text = 'testLastName';
      state.registerTextControllers['pass']!.text = 'testPass';
      state.registerTextControllers['passConfirm']!.text = 'testPass';
    });

    test('Password - Incorrect Length', () {
      state.registerTextControllers['pass']!.text = 'p';
      expect(state.verifyUserInfo(), false);
    });

    test('Password - Not Matching', () {
      state.registerTextControllers['pass']!.text = 'testPass';
      state.registerTextControllers['passConfirm']!.text = 'testPassConfirm';
      expect(state.verifyUserInfo(), false);
    });

    test('Password - Valid', () {
      widget = const RegisterDBStub();
      element = widget.createElement();
      state = element.state as RegisterDBStubState;
      state.registerTextControllers['email']!.text = 'test@wisc.edu';
      state.registerTextControllers['firstName']!.text = 'testFirstName';
      state.registerTextControllers['lastName']!.text = 'testLastName';
      state.registerTextControllers['pass']!.text = 'testPass';
      state.registerTextControllers['passConfirm']!.text = 'testPass';
      expect(state.verifyUserInfo(), true);
    });
  });

  group('registerDB', () {
    var widget = const Register();
    var element = widget.createElement();
    var state = element.state as RegisterState;
    var database = MockDatabaseMockito();
    Database.instance = database;

    setUp(() {
      widget = const Register();
      element = widget.createElement();
      state = element.state as RegisterState;
      state.registerTextControllers['email']!.text = 'test@wisc.edu';
      state.registerTextControllers['firstName']!.text = 'testFirstName';
      state.registerTextControllers['lastName']!.text = 'testLastName';
      state.registerTextControllers['pass']!.text = 'testPass';
      state.registerTextControllers['passConfirm']!.text = 'testPass';
    });

    test('Failed Registration', () async {
      String creationDate = 'testDate';

      Map<String, String> dbValues = {
        'email': sha256.convert(utf8.encode(state.registerTextControllers['email']!.text.toLowerCase().trim())).toString(),
        'firstName': state.registerTextControllers['firstName']!.text,
        'lastName': state.registerTextControllers['lastName']!.text,
        'password': sha256.convert(utf8.encode(state.registerTextControllers['pass']!.text)).toString(),
        'date': creationDate
      };

      when(database.insert('User', dbValues)).thenAnswer((_) async => false);
      expect(await state.registerDB(creationDate), false);
    });

    test('Successful Registration', () async {
      String creationDate = 'testDate';

      Map<String, String> dbValues = {
        'email': sha256.convert(utf8.encode(state.registerTextControllers['email']!.text.toLowerCase().trim())).toString(),
        'firstName': state.registerTextControllers['firstName']!.text,
        'lastName': state.registerTextControllers['lastName']!.text,
        'password': sha256.convert(utf8.encode(state.registerTextControllers['pass']!.text)).toString(),
        'date': creationDate
      };

      when(database.insert('User', dbValues)).thenAnswer((_) async => true);

      try {
        await state.registerDB(creationDate);
      }
      catch (e) {
        expect(User.userEmail, state.registerTextControllers['email']!.text.toLowerCase().trim());
        expect(User.firstName, state.registerTextControllers['firstName']!.text);
        expect(User.lastName, state.registerTextControllers['lastName']!.text);
        expect(User.creationDate, creationDate);
      }
    });
  });
}