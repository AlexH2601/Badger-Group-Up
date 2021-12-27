import 'package:badger_group_up/src/pages/create_session/create_session_page.dart';
import 'package:badger_group_up/src/system/database.dart';
import 'package:badger_group_up/src/system/shared_values.dart';
import 'package:flutter/material.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:badger_group_up/src/system/session_manager/session_entry.dart';
import 'package:badger_group_up/src/system/session_manager/session_manager.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../database.mocks.dart';

void main() {
  group('SessionManager', () {
    var sessionManager = SessionManager();
    var database = MockDatabaseMockito();
    setUp(() {
      debugPrint("Set up test");
      sessionManager = SessionManager();
      database = MockDatabaseMockito();
      Database.instance = database;
    });


    test('Test mock database override', () async {
      bool expectedReturn= false;
      when(database.delete(Relation.Session.getName(), {})).thenAnswer((_) async => expectedReturn);
      bool res = await sessionManager.dbtest();
      expect(res, expectedReturn);
    });


    test('LoadSessions - success', () async {
      when(database.select(Relation.Session.getName()))
          .thenAnswer((_) async => [
            ['test@test.test/2021-11-03 13:49:38.097657',
        'test@test.test', 'La Crosse', '0','2021-11-03 13:49:38.097657','2021-11-03 14:49:38.097657',5,0,0, ]]);
      bool success = await sessionManager.loadSessions();
      expect(success, true);
      for (var i in sessionManager.sessionList) {
        expect(sessionManager.getSessionByID(i.id), isNotNull);
      }
    });


    ///removeSession
    test('Remove Session - fail', () async {
      String id = 'exist';
      Map<String, String> conditionals = {
        'id': id,
      };
      when(database.delete(Relation.Session.getName(), conditionals))
          .thenAnswer((_) async => true);
      bool res = await sessionManager.removeSession(id);
      expect(res, false);
    });




    test('GetSessionByID - not found', () {
      //  when(sessionManager.getSessionByID('I do not exist')).thenReturn(null);
      SessionEntry? res = sessionManager.getSessionByID('I do not exist');
      expect(res == null, true);
    });

    test('CreateSession - success', () async {
      var entry = SessionEntry.fromDB(['test@test.test/2021-11-03 13:49:38.097657',
        'test@test.test', 'La Crosse', '0','2021-11-03 13:49:38.097657','2021-11-03 14:49:38.097657',5,0,0, ]);
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
      bool res = await sessionManager.createSession(entry);
      expect(res == true, true);

      res = sessionManager.hasSession(entry.id);
      expect(res == true, true);


    });

    test('CreateSession - success', () async {
      var entry = SessionEntry.fromDB(['test@test.test/2021-11-03 13:49:38.097657',
        'test@test.test', 'La Crosse', '0','2021-11-03 13:49:38.097657','2021-11-03 14:49:38.097657',5,0,0, ]);

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

      bool res = await sessionManager.createSession(entry);
      expect(res == true, true);

      entry.status = SessionStatus.Closed;
      Map<String, String> newValues = {
        'status': entry.status.index.toString(),
      };
      Map<String, String> conditionals = {
        'id': entry.id,
      };
      when(database.update(Relation.Session.getName(), newValues, conditionals)).thenAnswer((_) async => true);

      res = await sessionManager.pushUpdateOnEntry(entry);
      expect(res == true, true);

      var newEntry = sessionManager.getSessionByID(entry.id);
      debugPrint(newEntry.toString());
      expect(newEntry !=null , true);
      expect(newEntry!.status == SessionStatus.Closed, true);
    });

    // showSessionDetail
    // findNextSessionAfter
    // checkScheduleCollision
    // getSessionsIn
  });


  group('SessionManager - Scheduling', () {
    var sessionManager = SessionManager();
    var database = MockDatabaseMockito();
    setUp(() {
      debugPrint("Set up test");
      sessionManager = SessionManager();
      database = MockDatabaseMockito();

      when(database.select(Relation.Session.getName()))
          .thenAnswer((_) async => [
            //Test for COvering
        ['test@test.test/0',
          'test@test.test', 'La Crosse', '0','2021-11-03 16:10','2021-11-03 16:20',5,0,0, ],
        //Test for Being covered
        ['test@test.test/1',
          'test@test.test', 'La Crosse', '0','2021-11-03 16:30','2021-11-03 16:45',5,0,0, ],
        //Test for Left end , Right end
        ['test@test.test/2',
          'test@test.test', 'La Crosse', '0','2021-11-03 17:00','2021-11-03 17:30',5,0,0, ],
        //Test for Jump for an hour, Fill in 30 min
        ['test@test.test/3',
          'test@test.test', 'La Crosse', '0','2021-11-03 18:00','2021-11-03 18:30',5,0,0, ],
        //Test No more schedule today
        ['test@test.test/4',
          'test@test.test', 'La Crosse', '0','2021-11-03 22:00','2021-11-03 23:59',5,0,0, ],

      ]);
      Database.instance = database;
      sessionManager.loadSessions();
    });


    test('Schedule - Cover and Fail', () async {
      SessionEntry entry = SessionEntry.fromDB(['testID', 'testEmail', 'La Crosse', '0',
        '2021-11-03 16:00','2021-11-03 16:30',5,0,0, ]);
      SessionEntry? test = sessionManager.isScheduleCompatible(entry);
      expect(test, isNotNull);
      //sessionManager.setEarliestCompatibleSchedule(entry, start, duration)
    });
    test('Schedule - Cover and Fail', () async {
      var d = sessionManager.timeSinceLastUpdate();
      expect(d>=0, true);
      //sessionManager.setEarliestCompatibleSchedule(entry, start, duration)
    });

    test('Schedule - Get covered and Fail', () async {
      SessionEntry entry = SessionEntry.fromDB(['testID', 'testEmail', 'La Crosse', '0',
        '2021-11-03 16:35','2021-11-03 16:40',5,0,0, ]);
      SessionEntry? test = sessionManager.isScheduleCompatible(entry);
      expect(test, isNotNull);
    });

    test('Schedule - Collision On left', () async {
      SessionEntry entry = SessionEntry.fromDB(['testID', 'testEmail', 'La Crosse', '0',
        '2021-11-03 16:50','2021-11-03 17:01',5,0,0, ]);
      SessionEntry? test = sessionManager.isScheduleCompatible(entry);
      expect(test, isNotNull);
    });
    test('Schedule - Collision On Right', () async {
      SessionEntry entry = SessionEntry.fromDB(['testID', 'testEmail', 'La Crosse', '0',
        '2021-11-03 17:29','2021-11-03 17:31',5,0,0, ]);
      SessionEntry? test = sessionManager.isScheduleCompatible(entry);
      expect(test, isNotNull);
    });
    test('Schedule - Collision On Left and Right', () async {
      SessionEntry entry = SessionEntry.fromDB(['testID', 'testEmail', 'La Crosse', '0',
        '2021-11-03 16:44','2021-11-03 17:01',5,0,0, ]);
      SessionEntry? test = sessionManager.isScheduleCompatible(entry);
      expect(test, isNotNull);
    });
    test('Schedule - Pittari success', () async {
      SessionEntry entry = SessionEntry.fromDB(['testID', 'testEmail', 'La Crosse', '0',
        '2021-11-03 16:45','2021-11-03 17:00',5,0,0, ]);
      SessionEntry? test = sessionManager.isScheduleCompatible(entry);
      expect(test, isNull);
    });

    test('Schedule - Find 30 min long session success', () async {
      SessionEntry entry = SessionEntry.fromDB(['testID', 'testEmail', 'La Crosse', '0',
        '2021-11-03 16:45','2021-11-03 17:00',5,0,0, ]);
      DateTime start = DateTime.parse('2021-11-03 17:00');
      DateTime expectedStart = DateTime.parse('2021-11-03 17:30');
      DateTime expectedEnd = DateTime.parse('2021-11-03 18:00');
      Duration duration = const Duration(minutes: 30);
      bool success = sessionManager.setEarliestCompatibleSchedule(entry, start, duration);
      expect(success, true);
      expect(entry.getBegin().hour,expectedStart.hour);
      expect(entry.getBegin().minute,expectedStart.minute);
      expect(entry.getEnd().hour,expectedEnd.hour);
      expect(entry.getEnd().minute,expectedEnd.minute);
    });
    test('Schedule - Jump for an hour', () async {
      SessionEntry entry = SessionEntry.fromDB(['testID', 'testEmail', 'La Crosse', '0',
        '2021-11-03 16:45','2021-11-03 17:00',5,0,0, ]);
      DateTime start = DateTime.parse('2021-11-03 16:00');
      Duration duration = const Duration(hours: 1);

      DateTime expectedStart = DateTime.parse('2021-11-03 18:30');
      DateTime expectedEnd = DateTime.parse('2021-11-03 19:30');
      bool success = sessionManager.setEarliestCompatibleSchedule(entry, start, duration);
      expect(success, true);
      expect(entry.getBegin().hour,expectedStart.hour);
      expect(entry.getBegin().minute,expectedStart.minute);
      expect(entry.getEnd().hour,expectedEnd.hour);
      expect(entry.getEnd().minute,expectedEnd.minute);
    });


    test('Schedule - No More Time slot', () async {
      SessionEntry entry = SessionEntry.fromDB(['testID', 'testEmail', 'La Crosse', '0',
        '2021-11-03 16:45','2021-11-03 17:00',5,0,0, ]);
      DateTime start = DateTime.parse('2021-11-03 21:00');
      Duration duration = const Duration(hours: 2);

      bool success = sessionManager.setEarliestCompatibleSchedule(entry, start, duration);
      expect(success, false);
    });
  });

}
