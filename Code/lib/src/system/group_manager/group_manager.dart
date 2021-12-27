import 'package:badger_group_up/src/system/database.dart';
import 'package:badger_group_up/src/system/group_manager/group.dart';
import 'package:badger_group_up/src/system/session_manager/session_manager.dart';
import 'package:badger_group_up/src/system/shared_values.dart';
import 'package:badger_group_up/src/system/user.dart';
import 'package:flutter/material.dart';

///This class keeps track of sports activities. Intialises and reloads data
// from DB when necessary, sends changes, and then provides a session list
// to other classes.


class GroupManager {
  //static GroupManager instance = GroupManager();
  static final Map<String, Group> _groups = {};

  //SEMAPHORE
  static bool _loadingGroups = false;

  static Future<bool> loadGroups() async {
    if (_loadingGroups) return false;
    _loadingGroups = true;
    var response = await Database.instance.select(Relation.Group.getName());
    _loadingGroups = false;
    for (var g in _groups.values) {
      g.participants.clear();
    }
    _groups.clear();
    //if (response.isEmpty) return true;

    for (var list in response) {
      //sessionid, participantemail, firstname, lastname.
      _linkGroup(list[0], list[1]);
    }
    return true;
  }


  /// 1. DOnt allow 1 person multiple location at same time span
  /// 2. Dont allow 1 person join same group twice
  /// 3. Concurrency issue on current people is possible (6/ 5 case)
  static Future<bool> joinGroup(String sessionId) async {
    if(containsUser(sessionId, User.userEmail)) return false;
    Map<String, String> values = {
      'sessionid': sessionId,
      'participant_email': User.userEmail,
      'firstname': User.firstName,
      'lastname': User.lastName,
    };

    bool success = await Database.instance.insert(Relation.Group.getName(), values);
    if (success) {
      _linkGroup(sessionId, User.userEmail);
    }
    return success;
  }

  static Future<bool> removeAllfromUser(String userMail) async{
      var set = getSessionSetWith(userMail);
      bool res = true;
      for(var sid in set){
        var session = SessionManager.instance.getSessionByID(sid);
       // debugPrint("Remove Group "+session!.id);
        bool success = await removeFromGroup(session!.id);
        if(!success){
          res = false;
        }
      }
    return res;
  }

  static Future<bool> removeFromGroup(String sessionId) async {
    Map<String, String> conditionals = {
      'sessionid': sessionId,
      'participant_email': User.userEmail,
    };
    bool success = await Database.instance.delete(Relation.Group.getName(), conditionals);
    if (success) {
      int remaining = _unlinkGroup(sessionId, User.userEmail);
      if(remaining == 0){
        debugPrint("Remove session "+sessionId);
        success = await SessionManager.instance.removeSession(sessionId);
      }
    }
    return success;
  }

  ///Helper functions that locally removes group
  ///After they are removed on DB
  ///(Probably better than reloading DB?
  ///
  static void _linkGroup(String id, String email) {
    if (!_groups.containsKey(id)) {
      _groups[id] = Group(id);
    }
    _groups[id]!.addParticipant(email);
  }

  //Return number of remaining people in group after kicking this guy out.
  static int _unlinkGroup(String id, String email) {
    //In fact email is always User.email. Only I can kick me out.
    if (!_groupExists(id)) {
      return -1;
    }
    _groups[id]!.removeParticipant(email);
    if (_groups[id]!.isEmpty()) {
      _groups.remove(id);
      return 0;
    }else{
      return _groups[id]!.getNumberOfParticipants();
    }
  }

  static bool containsUser(String sessionId, String email){
    if (!_groups.containsKey(sessionId)) {
      return false;
    }else{
     return  _groups[sessionId]!.contains(email);
    }
  }

  static bool _groupExists(String sessionId){
    if(!_groups.containsKey(sessionId)){
      try{
        throw Exception("Session with id["+sessionId+"] is not found. May want to reload DB ?");
      }catch(Exception, stacktrace){
        debugPrint(Exception.toString());
       // debugPrint(stacktrace.toString());
      }
      return false;
    }else{
      return true;
    }
  }
  static Set<String> getSessionSetWith(String personEmail){
    Set<String> set = {};
    for(var group in _groups.values){
      if(group.contains(personEmail)){
        set.add(group.sessionID);
      }
    }
    return set;
  }

  static int getNumberOfPeopleInSession(String sessionId) {
    if (_groupExists(sessionId)) {
      return _groups[sessionId]!.getNumberOfParticipants();
    }else{
      return 0;
    }
  }
}
