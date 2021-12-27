import 'package:badger_group_up/src/pages/homescreen/home_screen_page.dart';
import 'package:badger_group_up/src/pages/homescreen/list_view_widget.dart';
import 'package:badger_group_up/src/pages/homescreen/map_view_widget.dart';
import 'package:badger_group_up/src/system/database.dart';
import 'package:badger_group_up/src/system/session_manager/session_manager.dart';
import 'package:badger_group_up/src/system/shared_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../database.mocks.dart';

void main() {
  var page = const HomeScreen();
  var database = MockDatabaseMockito();
  late HomeScreenState state;
  Type typeOf<T>() => T;
  Future<void> setUpState(WidgetTester tester) async{
    await tester.pumpWidget(page);
    state = tester.state(find.byType(HomeScreen));
  }
  group('Home Screen Widgets', () {
    setUp(() {
      page = const HomeScreen();
      database = MockDatabaseMockito();
      Database.instance=  database;
      when(database.select(Relation.Session.getName()))
          .thenAnswer((_) async => []);
      when(database.select(Relation.Group.getName()))
          .thenAnswer((_) async => []);

    });

    testWidgets('All widgets displayed', (WidgetTester tester) async {
      await setUpState(tester);
      expect(find.byType(IconButton), findsNWidgets(5));
      expect(find.byType(ElevatedButton), findsNWidgets(1));
      expect(find.byType(ListViewWidget), findsNWidgets(1));
      expect(find.byType(MapViewWidget), findsNWidgets(0));
    });
    testWidgets('ReloadDB', (WidgetTester tester) async {
      await setUpState(tester);
      await state.reloadDB();
      expect(SessionManager.instance.sessionList.length, 0);
    });
    testWidgets('SwitchView', (WidgetTester tester) async {
      await setUpState(tester);
      bool b =state.isMapView ;
      state.switchView();
      await tester.pump();
      expect(state.isMapView,!b);
      expect(find.byType(ListViewWidget), findsNWidgets(0));
      expect(find.byType(MapViewWidget), findsNWidgets(1));
    });


    testWidgets('SwitchView', (WidgetTester tester) async {
      await setUpState(tester);
      await tester.tap(find.byType(IconButton).at(2));
      await tester.pump();
      expect(find.byType(ListViewWidget), findsNWidgets(0));
      expect(find.byType(MapViewWidget), findsNWidgets(1));
    });

    Future<void> testCheckboxes(WidgetTester tester) async{
      expect(find.byType(Checkbox), findsNWidgets(3));
      for (int i = 0 ; i < find.byType(Checkbox).evaluate().length ; i++) {
        await tester.tap(find.byType(Checkbox).at(i));
        await tester.pump();
      }
    }

    Future<void> testClose(WidgetTester tester) async{
      await tester.tap(find.widgetWithText(ElevatedButton, 'Reset'));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Apply'));
      await tester.pump();
      expect(find.byType(ElevatedButton), findsNWidgets(1));
    }

    testWidgets('Push Filter', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home:page));
      state = tester.state(find.byType(HomeScreen));
      await tester.tap(find.widgetWithIcon(ElevatedButton, Icons.search));
      await tester.pump();
      expect(find.byType(ElevatedButton), findsNWidgets(3));
     await testCheckboxes(tester);
      await testClose(tester);
    });
    // testWidgets('Test timer', (WidgetTester tester) async {
    //   await tester.pumpWidget(MaterialApp(home:page));
    //   state = tester.state(find.byType(HomeScreen));
    //   state.stopTimer();
    //   expect(state.isStopped,true);
    // });
    // testWidgets('Test timer duplicates', (WidgetTester tester) async {
    //   await tester.pumpWidget(MaterialApp(home:page));
    //   state = tester.state(find.byType(HomeScreen));
    //   state.fireTimerForReload();
    //   state.fireTimerForReload();
    //   expect(state.isStopped,false);
    // });


  });
}