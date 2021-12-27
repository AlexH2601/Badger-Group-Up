import 'package:badger_group_up/src/system/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('loadUserInfo', () {
    test('Email Missing', () {
      Map<String, String> userValues = {
        'firstName': 'testFirstName',
        'lastName': 'testLastName',
        'creationDate': 'testDate'
      };
      expect(User.loadUserInfo(userValues), false);
    });

    test('First Name Missing', () {
      Map<String, String> userValues = {
        'email': 'testEmail',
        'lastName': 'testLastName',
        'creationDate': 'testDate'
      };
      expect(User.loadUserInfo(userValues), false);
    });

    test('Last Name Missing', () {
      Map<String, String> userValues = {
        'email': 'testEmail',
        'firstName': 'testFirstName',
        'creationDate': 'testDate'
      };
      expect(User.loadUserInfo(userValues), false);
    });

    test('Creation Date Missing', () {
      Map<String, String> userValues = {
        'email': 'testEmail',
        'firstName': 'testFirstName',
        'lastName': 'testLastName'
      };
      expect(User.loadUserInfo(userValues), false);
    });

    test('No Fields Missing', () {
      Map<String, String> userValues = {
        'email': 'testEmail',
        'firstName': 'testFirstName',
        'lastName': 'testLastName',
        'creationDate': 'testDate'
      };
      expect(User.loadUserInfo(userValues), true);

      expect(User.userEmail, 'testEmail');
      expect(User.firstName, 'testFirstName');
      expect(User.lastName, 'testLastName');
      expect(User.creationDate, 'testDate');
    });
  });

  test('Logout', () {
    User.userEmail = 'testEmail';
    User.firstName = 'testFirstName';
    User.lastName = 'testLastName';
    User.creationDate = 'testDate';

    User.logout();

    expect(User.userEmail, '');
    expect(User.firstName, '');
    expect(User.lastName, '');
    expect(User.creationDate, '');
  });
}