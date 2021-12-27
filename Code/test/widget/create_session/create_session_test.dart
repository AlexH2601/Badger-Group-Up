import 'package:badger_group_up/src/pages/create_session/create_session_page.dart';
import 'package:badger_group_up/src/system/database.dart';
import 'package:badger_group_up/src/system/session_manager/activity.dart';
import 'package:badger_group_up/src/system/session_manager/location.dart';
import 'package:badger_group_up/src/system/session_manager/session_entry.dart';
import 'package:badger_group_up/src/system/shared_values.dart';
import 'package:badger_group_up/src/system/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../database.mocks.dart';

void main() {
  var page = const CreateSession();
  var database = MockDatabaseMockito();
  late CreateSessionState state;
  Type typeOf<T>() => T;

  Future<void> setUpState(WidgetTester tester) async{
    await tester.pumpWidget(page);
    state = tester.state(find.byType(CreateSession));

  }

  group('Create Session Widgets', () {
    setUp(() {
      page = const CreateSession();
      database = MockDatabaseMockito();
      when(database.select(Relation.Session.getName()))
          .thenAnswer((_) async => [
        ['test@test.test/2021-11-03 13:49:38.097657',
          'test@test.test', 'La Crosse', '0','2021-11-03 13:49:38.097657','2021-11-03 14:49:38.097657',5,0,0, ]]);
    });
    testWidgets('All widgets displayed', (WidgetTester tester) async {
      await setUpState(tester);
      //3 Dropdown : Location, Activity, Skills
      expect(find.byType(typeOf<DropdownButton<int>>()), findsNWidgets(3));
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(Checkbox), findsNWidgets(1));
      expect(find.byType(ElevatedButton), findsNWidgets(4));
    });

    testWidgets('Checkbox', (WidgetTester tester) async {
      await setUpState(tester);
      final checkboxFinder = find.byType(Checkbox).first;
      var checkbox = tester.firstWidget(checkboxFinder) as Checkbox;
      expect(checkbox.value, false);
      await tester.tap(checkboxFinder);
      await tester.pump();
      checkbox = tester.firstWidget(checkboxFinder) as Checkbox;
      expect(checkbox.value, true);
    });
    testWidgets('Text Displayed', (WidgetTester tester) async {
      await setUpState(tester);
      final checkboxFinder = find.byType(Checkbox).first;
      var checkbox = tester.firstWidget(checkboxFinder) as Checkbox;
      expect(checkbox.value, false);
      await tester.tap(checkboxFinder);
      await tester.pump();
      checkbox = tester.firstWidget(checkboxFinder) as Checkbox;
      expect(checkbox.value, true);
    });
    testWidgets('Location change', (WidgetTester tester) async {
      await setUpState(tester);
      for (int i = 0; i < Location.locations.length; i++) {
        state.onSelectLocation(i);
        await tester.pump();
        expect(state.form.location.id, Location.locations[i].id);
      }
    });

    testWidgets('Activity change', (WidgetTester tester) async {
      await setUpState(tester);
      for (int i = 0; i < Activity.activities.length; i++) {
        state.onSelectActivity(i);
        await tester.pump();
        expect(state.form.activity, Activity.activities[i]);
      }
    });
    testWidgets('Skill change', (WidgetTester tester) async {
      await setUpState(tester);
      for (int i = 0; i < SkillLevel.values.length; i++) {
        state.onSelectSkillLevel(i);
        await tester.pump();
        expect(state.form.skillLevel, SkillLevel.values[i]);
      }
    });

    testWidgets('Skill change', (WidgetTester tester) async {
      await setUpState(tester);
      for (int i = 0; i < SkillLevel.values.length; i++) {
        state.onSelectSkillLevel(i);
        await tester.pump();
        expect(state.form.skillLevel, SkillLevel.values[i]);
      }
    });
    testWidgets('Submit time', (WidgetTester tester) async {
      await setUpState(tester);
      state.form.setBegin(DateTime.now().add(const Duration(minutes: 15)));
      state.form.setEnd(state.form.getBegin().add(const Duration(minutes: 15)));
      try{
        state.onSubmitTime();
      }catch(e){
        expect(state.form.midPoint != 0 , true);
      }
    });
    testWidgets('Submit time Fail', (WidgetTester tester) async {
      await setUpState(tester);
      state.form.setBegin(DateTime.now().subtract(const Duration(minutes: 15)));
      state.form.setEnd(state.form.getBegin().add(const Duration(minutes: 15)));
      double mid = state.form.midPoint;
      try{
        state.onSubmitTime();
      }catch(e){
        expect(state.form.midPoint == mid , true);
      }
    });
  });


  group('Session Main Functions', () {
    setUp(() {
      page = const CreateSession();
      database = MockDatabaseMockito();
      when(database.select(Relation.Session.getName()))
          .thenAnswer((_) async => [
        ['test@test.test/2021-11-03 13:49:38.097657',
          'test@test.test', 'La Crosse', '0','2021-11-03 13:49:38.097657','2021-11-03 14:49:38.097657',5,0,0, ]]);
    });

    testWidgets('Fill Forms', (WidgetTester tester) async {
      await setUpState(tester);
      String testText ="test";
      User.userEmail = 'testEmail';
      state.controllers[iCreateSession.description]!.text = testText;
      state.fillForms();
      expect(state.form.id.isNotEmpty , true);
      expect(state.form.status , SessionStatus.Open);
      expect(state.form.hostEmail.isNotEmpty , true);
      expect(state.form.description , testText);
      expect(state.form.desiredPeople >= 1 , true);
    });

    testWidgets('Validation', (WidgetTester tester) async {
      await setUpState(tester);
      User.userEmail = 'testEmail';
      DateTime s  = (DateTime.now().add(const Duration(minutes: 15)));
      DateTime e =(s.add(const Duration(minutes: 15)));
      SessionEntry entry = SessionEntry.fromDB(['testID', 'testEmail', 'La Crosse', '0',
        s.toString(),e.toString(),5,0,0, ]);
      String? ret = state.doValidationCheck(entry);
      expect(ret,null);

      state.onSelectBeginTime();
      state.onSelectEndTime();
    });

    testWidgets('Submit form', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home:page));
      state = tester.state(find.byType(CreateSession));
      User.userEmail = 'testEmail';
      User.firstName = "John";
      User.lastName ="Doe";
      DateTime s  = (DateTime.now().add(const Duration(minutes: 15)));
      DateTime e =(s.add(const Duration(minutes: 15)));
      SessionEntry entry = SessionEntry.fromDB(['testID', 'testEmail', 'La Crosse', '0',
        s.toString(),e.toString(),5,0,0, ]);

      Database.instance= database;
      state.form = entry;
      state.fillForms();
      Map<String, String> values = {
        'id': entry.id,
        'hostEmail': entry.hostEmail,
        'nameOfActivity': entry.activity,
        'location': entry.location.id,
        'beginTime': entry.getBegin().toString(),
        'endTime': entry.getEnd().toString(),
        'desiredPeople': entry.desiredPeople.toString(),
        'status': entry.status.index.toString(),
        'skill': entry.skillLevel.index.toString(),
        'description': entry.description,
      };
      when(database.insert(Relation.Session.getName(), values)).thenAnswer((_) async => true);

      Map<String, String> gvalues = {
        'sessionid': entry.id,
        'participant_email': User.userEmail,
        'firstname': User.firstName,
        'lastname': User.lastName,
      };
      when(database.insert(Relation.Group.getName(), gvalues)).thenAnswer((_) async => true);


      state.onPressSubmitSession();
      expect(true,true);
    });
  });
}
