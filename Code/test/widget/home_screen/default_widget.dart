import 'package:badger_group_up/src/pages/homescreen/home_screen_page.dart';
import 'package:badger_group_up/src/pages/homescreen/list_view_widget.dart';
import 'package:badger_group_up/src/system/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../database.mocks.dart';

void main() {
  ///Default Template for Page test
  var page = ListViewWidget();
  var database = MockDatabaseMockito();
  var state = ListViewWidgetState();
  Type typeOf<T>() => T;
  Future<void> setUpState(WidgetTester tester) async{
    await tester.pumpWidget(page);
    state = tester.state(find.byType(page.runtimeType));
    await tester.pump();
  }
  group('Widgets', () {
    setUp(() {
      page = ListViewWidget();
      database = MockDatabaseMockito();
      Database.instance=  database;
    });

    testWidgets('All widgets displayed', (WidgetTester tester) async {
      await setUpState(tester);
    });
  });
}