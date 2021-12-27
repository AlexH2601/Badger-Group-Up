part of 'package:badger_group_up/src/system/session_manager/session_manager.dart';
extension SessionManagerScheduler on SessionManager {



  ///Is Schedule Function
  bool setEarliestCompatibleSchedule(
      SessionEntry entry, DateTime start, Duration duration) {
    entry.setBegin(start);
    entry.setEnd(start.add(duration));
    int today = entry.getEnd().day;
    var sessions = findSessionForCollision(entry);
    bool solutionFound = true;
    for (var s in sessions) {
      debugPrint("Find session "+s.location.name+" : "+s.timeToString());
      if (s.getEnd().isAfter(entry.getBegin())) {
        if (!s.isCompatibleWith(entry)) {
          var diff = s.getEnd().difference(entry.getBegin());
          entry.pushScheduleBy(diff);
          if (entry.getEnd().day != today
          // ||(entry.getEnd().day ==(today +1) && entry.isMidnight()))
          ) {
            solutionFound = false;
            break;
          }
        } else {
          solutionFound = true;
          break;
        }
      }
    }

    return solutionFound;
  }
  List<SessionEntry> findSessionForCollision(SessionEntry entry){
    var sessionsIn = getSessionIDSetIn(entry.location.id);
    var sessionsWithMe = GroupManager.getSessionSetWith(User.userEmail);
    //1 build a complete set
    for(var s in sessionsWithMe){
      debugPrint("Found session with me "+s);
      if(!sessionsIn.contains(s)){
        sessionsIn.add(s);
      }
    }
    //2 build list
    List<SessionEntry> sessionList = [];
    for(var s in sessionsIn){
      var session = getSessionByID(s);
      if(session == null) continue;
      sessionList.add(session);
    }
    //3 sort
    sessionList =  sortSessionsList(sessionList);
    return sessionList;
  }
  ///Is Schedule Function
  ///Returns the first incompatible schedule in ascending order of time.
  SessionEntry? isScheduleCompatible(SessionEntry entry) {
    var sessions = findSessionForCollision(entry);
    for (var s in sessions) {
      if (!s.isCompatibleWith(entry)) {
        debugPrint(entry.timeToString() + " is NOT compatible");
        return s;
      }
    }
    debugPrint(entry.timeToString() + " is compatible");
    return null;
  }
}