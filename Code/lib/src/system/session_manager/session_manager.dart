import 'package:badger_group_up/src/system/database.dart';
import 'package:badger_group_up/src/system/group_manager/group_manager.dart';
import 'package:badger_group_up/src/system/session_manager/location.dart';
import 'package:badger_group_up/src/system/session_manager/session_entry.dart';
import 'package:badger_group_up/src/system/shared_values.dart';
import 'package:badger_group_up/src/system/user.dart';
import 'package:badger_group_up/src/widgets/button_factory.dart';
import 'package:badger_group_up/src/widgets/grid_factory.dart';
import 'package:flutter/material.dart';

part 'package:badger_group_up/src/system/session_manager/session_manager_ui_helper.dart';
part 'package:badger_group_up/src/system/session_manager/session_manager_scheduler.dart';
///This class keeps track of sports activities. Intialises and reloads data
// from DB when necessary, sends changes, and then provides a session list
// to other classes.
class SessionManager {
  static SessionManager instance = SessionManager();

  List<SessionEntry> sessionList = [];
  Map<String, SessionEntry> _sessionMap = Map<String, SessionEntry>();

  bool _isLoadingSession = false;
  DateTime lastUpdate = DateTime.now();
  Future<bool> loadSessions() async {
    if (_isLoadingSession) return false;
    _isLoadingSession = true;
    //Map<String, String> conditionalValues = {'status': SessionStatus.Done.index.toString()};
    var response = await Database.instance.select(Relation.Session.getName());
    _isLoadingSession = false;
    _clearData();
    for (int i = 0; i < response.length; i++) {
      var entry = SessionEntry.fromDB(response[i]);
      sessionList.add(entry);
      // debugPrint("Load " + entry.timeToString());
    }
    sortSessions();
    _buildMap();
    lastUpdate = DateTime.now();
    return true;
  }
  double timeSinceLastUpdate(){
    var now = DateTime.now();
    var diff = now.millisecondsSinceEpoch - lastUpdate.millisecondsSinceEpoch;
    return diff / 1000;
  }

  void _buildMap() {
    for (var e in sessionList) {
      _sessionMap[e.id] = e;
    }
  }

  void _clearData() {
    sessionList.clear();
    _sessionMap.clear();
  }

  SessionEntry? getSessionByID(String id) {
    if (_sessionMap.containsKey(id)) {
      return _sessionMap[id];
    } else {
      try {
        throw Exception("Session with id[" +
            id +
            "] is not found. May want to reload DB ?");
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
      }
      return null;
    }
  }

  Future<bool> removeSession(String id) async {
    //(MockDB db, String id)
    /// Call delete from Database.dart
// b. No matter the return value from database call, reload request
// list
// c. Return success
    Map<String, String> conditionals = {
      'id': id,
    };
    bool success = await Database.instance
        .delete(Relation.Session.getName(), conditionals);
    if (success) {
      success = _removeSession(id);
    }
    return success;
  }

  Future<bool> dbtest() async {
    bool success =
        await Database.instance.delete(Relation.Session.getName(), {});
    debugPrint(success.toString());
    return success;
  }

  Future<bool> createSession(SessionEntry entry) async {
    ///a. Call Insert from Database.dart to add new request
// b. No matter the return value from database call, reload request
// list
// c. Return success

    Map<String, String> values = {
      'id': entry.id,
      'hostEmail': entry.hostEmail,
      'nameOfActivity': entry.activity,
      'location': entry.location.id,
      'beginTime': entry.getBegin().toString(),
      'endTime': entry.getEnd().toString(),
      //  'currentPeople': entry.currentPeople.toString(),
      'desiredPeople': entry.desiredPeople.toString(),
      'status': entry.status.index.toString(),
      'skill': entry.skillLevel.index.toString(),
      'description': entry.description,
    };

    bool success =
        await Database.instance.insert(Relation.Session.getName(), values);
    if (success) {
      _addSession(entry);
    }
    return success;
  }

  bool hasSession(String id) {
    return _sessionMap.containsKey(id);
  }

  Future<bool> pushUpdateOnEntry(SessionEntry entry) async {
    ///Parse entry and push update on db.
    // b. Return success
    Map<String, String> newValues = {
      'status': entry.status.index.toString(),
    };
    Map<String, String> conditionals = {
      'id': entry.id,
    };

    bool success = await Database.instance
        .update(Relation.Session.getName(), newValues, conditionals);
    if (success) {
      success = _updateSession(entry);
      debugPrint("Update " + success.toString());
    }
    return success;
  }
  List<SessionEntry> getSessionsIn(String location) {
    //Returns list of sessions at the given location.
    List<SessionEntry> filtered = [];
    for (var e in sessionList) {
      if (e.location.id == location) filtered.add(e);
    }
    return filtered;
  }
  Set<String> getSessionIDSetIn(String location) {
    Set<String> filtered = {};
    for (var e in sessionList) {
      if (e.location.id == location) filtered.add(e.id);
    }
    return filtered;
  }



  bool _addSession(SessionEntry entry) {
    sessionList.add(entry);
    _sessionMap[entry.id] = entry;
    sortSessions();
    return true;
  }

  void sortSessions() {
    sessionList.sort((a, b) => a.midPoint.compareTo(b.midPoint));
  }

  List<SessionEntry> sortSessionsList(List<SessionEntry> list) {
    list.sort((a, b) => a.midPoint.compareTo(b.midPoint));
    return list;
  }
  bool _removeSession(String id) {
    if (!_sessionMap.containsKey(id)) return false;
    _sessionMap.remove(id);
    for (int i = 0; i < sessionList.length; i++) {
      if (sessionList[i].id == id) {
        sessionList.removeAt(i);
        return true;
      }
    }
    return false;
  }

  bool _updateSession(SessionEntry entry) {
    _sessionMap[entry.id] = entry;
    bool sessionFound = false;
    for (int i = 0; i < sessionList.length; i++) {
      if (sessionList[i].id == entry.id) {
        sessionList[i] = entry;
        sessionFound = true;
        break;
      }
    }
    sortSessions();
    return sessionFound;
  }
}
