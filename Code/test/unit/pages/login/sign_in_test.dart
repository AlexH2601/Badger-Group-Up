import 'package:badger_group_up/src/pages/login/sign_in_page.dart';
import 'package:badger_group_up/src/system/database.dart';
import 'package:badger_group_up/src/system/save_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../../../database.mocks.dart';

class LoginDBStub extends SignIn {
  const LoginDBStub({Key? key}) : super(key: key);

  @override
  LoginDBStubState createState() => LoginDBStubState();
}

class LoginDBStubState extends SignInState<LoginDBStub> {
  @override
  dynamic loginDB() async {}
}

void main() {
  group('verifyUserInfo - Empty', () {
    var widget = const SignIn();
    var element = widget.createElement();
    var state = element.state as SignInState;

    setUp(() {
      widget = const SignIn();
      element = widget.createElement();
      state = element.state as SignInState;
    });

    test('Init', () {
      expect(state.verifyUserInfo(), false);
    });

    test('Email Empty', () {
      state.loginTextControllers['pass']!.text = 'testPass';
      expect(state.verifyUserInfo(), false);
    });

    test('Password Empty', () {
      state.loginTextControllers['email']!.text = 'test@wisc.edu';
      expect(state.verifyUserInfo(), false);
    });
  });

  group('verifyUserInfo - Fields', () {
    var widget = const SignIn();
    var element = widget.createElement();
    var state = element.state as SignInState;

    setUp(() {
      widget = const SignIn();
      element = widget.createElement();
      state = element.state as SignInState;
    });

    test('Invalid Email', () {
      state.loginTextControllers['email']!.text = 'testEmail';
      state.loginTextControllers['pass']!.text = 'testPass';
      expect(state.verifyUserInfo(), false);
    });

    test('Invalid Password', () {
      state.loginTextControllers['email']!.text = 'test@wisc.edu';
      state.loginTextControllers['pass']!.text = 't';
      expect(state.verifyUserInfo(), false);
    });

    test('Valid Password', () {
      widget = const LoginDBStub();
      element = widget.createElement();
      state = element.state as LoginDBStubState;
      state.loginTextControllers['email']!.text = 'test@wisc.edu';
      state.loginTextControllers['pass']!.text = 'testPass';
      expect(state.verifyUserInfo(), true);
    });
  });

  group('loginDB', () {
    var widget = const SignIn();
    var element = widget.createElement();
    var state = element.state as SignInState;
    var database = MockDatabaseMockito();
    Database.instance = database;

    setUp(() {
      widget = const SignIn();
      element = widget.createElement();
      state = element.state as SignInState;
      state.loginTextControllers['email']!.text = 'test@wisc.edu';
      state.loginTextControllers['pass']!.text = 'testPass';
    });

    test('Failed Login', () async {
      Map<String, String> dbValues = {
        'email': sha256.convert(utf8.encode(state.loginTextControllers['email']!.text.toLowerCase().trim())).toString(),
        'password': sha256.convert(utf8.encode(state.loginTextControllers['pass']!.text)).toString(),
      };

      when(database.select('User', conditionals: dbValues)).thenAnswer((_) async => []);
      expect(await state.loginDB(), false);
    });
  });

  group('Credential Saving', () {
    var widget = const SignIn();
    var element = widget.createElement();
    var state = element.state as SignInState;

    setUp(() {
      widget = const SignIn();
      element = widget.createElement();
      state = element.state as SignInState;
      state.loginTextControllers['email']!.text = 'test@wisc.edu';
      state.loginTextControllers['pass']!.text = 'testPass';
    });

    tearDown(() {
      SaveManager.instance.saveBool('IsCredentialSaved', false);
      SaveManager.instance.saveString('myId', null);
      SaveManager.instance.saveString('myCode', null);
      SaveManager.instance = SaveManager();
    });

    test('Save Credentials Checkbox', () async {
        state.onCheckSaveCredentials(true);
        expect(state.autoLoginEnabled, true);

        state.onCheckSaveCredentials(false);
        expect(state.autoLoginEnabled, false);
    });

    test('Save Auto Login', () async {
      state.autoLoginEnabled = true;

      state.saveAutoLogin();

      expect(await SaveManager.instance.loadString('myId'), state.loginTextControllers['email']!.text);
      expect(await SaveManager.instance.loadString('myCode'), state.loginTextControllers['pass']!.text);
    });

    test('Load Auto Login', () async {
      widget = const LoginDBStub();
      element = widget.createElement();
      state = element.state as LoginDBStubState;
      state.loginTextControllers['email']!.text = 'test@wisc.edu';
      state.loginTextControllers['pass']!.text = 'testPass';

      state.onCheckSaveCredentials(true);
      state.saveAutoLogin();

      state.loginTextControllers['email']!.text = '';
      state.loginTextControllers['pass']!.text = '';

      await state.loadAutoLogin();
      expect(state.loginTextControllers['email']!.text, 'test@wisc.edu');
      expect(state.loginTextControllers['pass']!.text, 'testPass');
    });
  });
}