import 'package:badger_group_up/src/system/database.dart';
import 'package:badger_group_up/src/system/group_manager/group_manager.dart';
import 'package:badger_group_up/src/system/shared_values.dart';
import 'package:badger_group_up/src/system/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../database.mocks.dart';

void main() {
  group('GroupManager', () {
    MockDatabaseMockito database;
    setUp(() {
      database = MockDatabaseMockito();
      Database.instance = database;
      when(database.select(Relation.Group.getName())).thenAnswer((_) async => [
        ['0', 'user1'],
        ['0', 'user2'],
      ]);
    });

    test('Email Missing', () async {
      await GroupManager.loadGroups();
      var set = GroupManager.getSessionSetWith('user1');
      expect(set.length, 1);
    });
  });
}