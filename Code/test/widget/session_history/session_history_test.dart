import 'package:badger_group_up/src/pages/homescreen/home_screen_page.dart';
import 'package:badger_group_up/src/pages/homescreen/list_view_widget.dart';
import 'package:badger_group_up/src/pages/session_history/session_history_page.dart';
import 'package:badger_group_up/src/system/database.dart';
import 'package:badger_group_up/src/system/group_manager/group_manager.dart';
import 'package:badger_group_up/src/system/session_manager/session_manager.dart';
import 'package:badger_group_up/src/system/shared_values.dart';
import 'package:badger_group_up/src/system/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../database.mocks.dart';

void main() {
  var page = const SessionHistory();
  var database = MockDatabaseMockito();
  var state = SessionHistoryState();
  Type typeOf<T>() => T;
  Future<void> setUpState(WidgetTester tester) async {
    await SessionManager.instance.loadSessions();
    await GroupManager.loadGroups();
    await tester.pumpWidget(MaterialApp(home:page));
    state = tester.state(find.byType(page.runtimeType));
    await tester.pump();
  }

  group('Widgets', () {
    setUp(() {
      User.userEmail="user1";
      page = const SessionHistory();
      database = MockDatabaseMockito();
      Database.instance = database;
      when(database.select(Relation.Session.getName()))
          .thenAnswer((_) async => [
                ['0', User.userEmail, 'La Crosse', '0', DateTime.now().toString(), DateTime.now().add(const Duration(hours: 1)).toString(), 5, 0, 0,],
                ['1', User.userEmail, 'La Crosse', '0', DateTime.now().toString(), DateTime.now().add(const Duration(hours: 1)).toString(), 1, 0, 0,],
             //   ['2', '2', 'La Crosse', '0', DateTime.now().subtract(const Duration(hours: 2)).toString(), DateTime.now().subtract(const Duration(hours: 1)).toString(), 5, 0, 0,]
              ]);
      when(database.select(Relation.Group.getName())).thenAnswer((_) async => [
            ['0', User.userEmail],
            ['0', 'user2'],
            ['1', User.userEmail],
          ]);
      Map<String, String> conditionals = {
        'sessionid': '0',
        'participant_email': User.userEmail,
      };
      Map<String, String> conditionals2 = {
        'sessionid': '1',
        'participant_email': User.userEmail,
      };
      Map<String, String> condSession = {
        'id': '0',
      };
      Map<String, String> condSession2 = {
        'id': '1',
      };
      when(database.delete(Relation.Group.getName(), conditionals)).thenAnswer((_) async => true);
      when(database.delete(Relation.Group.getName(), conditionals2)).thenAnswer((_) async => true);
      when(database.delete(Relation.Session.getName(), condSession)).thenAnswer((_) async => true);
      when(database.delete(Relation.Session.getName(), condSession2)).thenAnswer((_) async => true);
    });

    testWidgets('All widgets displayed', (WidgetTester tester) async {
      await setUpState(tester);
      debugPrint(find.byType(IconButton).evaluate().length.toString());
      debugPrint(find.byType(ElevatedButton).evaluate().length.toString());
      debugPrint(find.byType(ListView).evaluate().length.toString());
      debugPrint(find.byType(Text).evaluate().length.toString());
      expect(find.byType(IconButton), findsNWidgets(3));
      expect(find.byType(ElevatedButton), findsNWidgets(0));
      expect(find.byType(ListView), findsNWidgets(1));
      expect(find.byType(Text), findsNWidgets(9));
    }, skip:false);

    testWidgets('Leave Session at history', (WidgetTester tester) async {
      await setUpState(tester);
      var entry = SessionManager.instance.getSessionByID('0')!;
      expect(entry, isNotNull);
      expect(GroupManager.containsUser('0', User.userEmail), true);
      await tester.tap(find.byType(IconButton).at(0));
   //   expect((find.byType(TextField).evaluate().elementAt(i).widget as TextField).controller!.text, testData[i]);
      //await state.onPressDeleteHistory(entry);
      await tester.pump();
      expect(GroupManager.containsUser('0', User.userEmail), false);
    });
    testWidgets('Leave Session as last one', (WidgetTester tester) async {
      await setUpState(tester);
      var entry = SessionManager.instance.getSessionByID('1')!;
      expect(entry, isNotNull);
      expect(GroupManager.containsUser('1', User.userEmail), true);
      await tester.tap(find.byType(IconButton).at(1));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Leave'));
      await tester.pump();
      expect(GroupManager.containsUser('1', User.userEmail), false);
    });
  });
}
