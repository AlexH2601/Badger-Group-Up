import 'package:badger_group_up/src/pages/homescreen/home_screen_page.dart';
import 'package:badger_group_up/src/pages/homescreen/list_view_widget.dart';
import 'package:badger_group_up/src/system/database.dart';
import 'package:badger_group_up/src/system/group_manager/group_manager.dart';
import 'package:badger_group_up/src/system/session_manager/session_entry.dart';
import 'package:badger_group_up/src/system/session_manager/session_manager.dart';
import 'package:badger_group_up/src/system/shared_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../database.mocks.dart';

void main() {
  var page = ListViewWidget();
  var database = MockDatabaseMockito();
  late ListViewWidgetState state;
  Type typeOf<T>() => T;
  Future<void> setUpState(WidgetTester tester) async {
    await tester.pumpWidget(page);
    state = tester.state(find.byType(page.runtimeType));
  }

  group('Widgets', () {
    setUp(() {
      page = ListViewWidget();
      database = MockDatabaseMockito();
      Database.instance = database;
      when(database.select(Relation.Session.getName()))
          .thenAnswer((_) async => [
                [
                  '0',
                  'test@test.test',
                  'La Crosse',
                  '0',
                  DateTime.now().toString(),
                  DateTime.now().add(Duration(hours: 1)).toString(),
                  5,
                  0,
                  0,
                ],
                [//Full
                  '1',
                  'test@test.test',
                  'La Crosse',
                  '0',
                  DateTime.now().toString(),
                  DateTime.now().add(Duration(hours: 1)).toString(),
                  1,
                  0,
                  0,
                ],
                [
                  '2',
                  'test@test.test',
                  'La Crosse',
                  '0',
                  DateTime.now().toString(),
                  DateTime.now().subtract(Duration(hours: 1)).toString(),
                  5,
                  0,
                  0,
                ]
              ]);
      when(database.select(Relation.Group.getName())).thenAnswer((_) async => [
            ['0', 'user1'],
            ['1', 'user2'],
            //['2', 'user3'],
          ]);
    });

    testWidgets('All widgets displayed', (WidgetTester tester) async {
      await SessionManager.instance.loadSessions();
      await GroupManager.loadGroups();
      await setUpState(tester);
      await tester.pump();
      expect(find.byType(ElevatedButton), findsNWidgets(1));
      expect(find.byType(Text), findsNWidgets(4));
    });
    
    testWidgets('Show session dialog', (WidgetTester tester) async {
      await SessionManager.instance.loadSessions();
      await GroupManager.loadGroups();
      await tester.pumpWidget(MaterialApp(home:page));
      state = tester.state(find.byType(page.runtimeType));
      await tester.pump();

      var s = SessionManager.instance.getSessionByID('0');
      expect(s,isNotNull);
      var diag = SessionManager.instance.buildSessionDialog(null, s!);
      expect(diag,isNotNull);
    });
  });
}
