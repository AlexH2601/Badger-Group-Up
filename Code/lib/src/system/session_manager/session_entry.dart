import 'package:badger_group_up/src/system/group_manager/group_manager.dart';
import 'package:badger_group_up/src/system/session_manager/activity.dart';
import 'package:badger_group_up/src/system/session_manager/location.dart';
import 'package:badger_group_up/src/system/shared_values.dart';
import 'package:badger_group_up/src/system/user.dart';
import 'package:badger_group_up/src/widgets/dialog_factory.dart';
import 'package:flutter/material.dart';

class SessionEntry {
  String id = "";
  String hostEmail = "";
  String activity = Activity.getRandom();
  Location location = Location.dummy();
  String description = "";
  DateTime _beginTime = DateTime.now();
  DateTime _endTime = DateTime.now();
  int desiredPeople = 0;


  SessionStatus status = SessionStatus.Open;
  SkillLevel skillLevel = SkillLevel.NoPreference;

  ///Sorting
  double midPoint = 0;
  double range = 0;

  SessionEntry();

/*  SessionEntry.dummy(String email) {
    id = "";
    hostEmail = email;
    activity = Activity.getRandom();
    description = "Describe";
    location = Location.getRandom();
    _beginTime = DateTime.now();
    _endTime = DateTime.now().add(const Duration(hours: 1));
    setEpoch();
  }*/

  SessionEntry.fromDB(List<dynamic> list) {
    id = list[0].toString();
    hostEmail = list[1].toString();
    activity = list[2];
    location = Location.getLocationByID(list[3])!;
    _beginTime = DateTime.parse(list[4]);
    _endTime = DateTime.parse(list[5]);
    // currentPeople = int.parse(list[6]);
    desiredPeople = list[6];
    status = SessionStatus.values[list[7]];
    skillLevel = SkillLevel.values[list[8]];
    setEpoch();
  }

/*  bool updateStatus() {
    ///Status is Done if time now > endTime
// b. Status is Closed if currentPeople = desiredPeople
// c. Else status is Open
// d. If status changed, push update on database.dart
// e. Return if status changed
    return true;
  }*/

  void generateID() {
    id = '${User.userEmail}/${_beginTime.toString()}';
    setEpoch();
  }

  bool containsUser(String userMail){
    return GroupManager.containsUser(id, userMail);
  }
  bool isExpired() => DateTime.now().isAfter(_endTime);
  bool isFull()=> getCurrentPeopleNumber() >= desiredPeople;
  bool isOpen()=>!isExpired() && !isFull();
  bool isJoinable(String userMail){
    return isOpen() && !containsUser(userMail);
  }

  String peopleToString() {
    return '${getCurrentPeopleNumber()} / $desiredPeople';
  }

  int getCurrentPeopleNumber() => GroupManager.getNumberOfPeopleInSession(id);

  String timeToString() {
    return '${MyTheme.printTime(_beginTime)} ~ ${MyTheme.printTimeShort(_endTime)}'; //+':'+beginTime.minute+" ~ ";
  }

  bool isCompatibleWith(SessionEntry entry) {
    ///Collision detection is like circular collision detection but in 1d space.
    ///
    /// Two objects are colliding if center of 2 objects are shorter than sum of their radius.
    ///
    double distance = (midPoint - entry.midPoint).abs();
    double bound = range + entry.range;
    return distance >= bound;
  }
  DateTime convertIfMidnight(DateTime time){
    //1200am indicated tomorrow.
    if(time.hour==0 && time.minute == 0 && time.day == (DateTime.now().day + 1)){
      time = time.add(const Duration(days: 1));
    }
    return time;
  }

  void setBegin(DateTime time){
    _beginTime = convertIfMidnight(time);
   // setEpoch();
  }
  void setEnd(DateTime time){
    _endTime = convertIfMidnight(time);
    setEpoch();
  }
  DateTime getEnd()=> _endTime;
  DateTime getBegin()=>_beginTime;
  bool isMidnight()=> _endTime.hour == 0 && _endTime.minute == 0;

  void pushScheduleBy(Duration duration){
    setBegin(getBegin().add(duration));
    setEnd(getEnd().add(duration));
  }

  @override
  String toString(){
    return location.name+" : "+timeToString();
  }
  void setEpoch() {
    /// End time  - Begin Time = Duration from start to end
    ///
    /// Length : Duration of acitivity in Minutes (1 min = 60 seconds = 60000)
    var length =
        (_endTime.millisecondsSinceEpoch - _beginTime.millisecondsSinceEpoch) ~/
            (60000);

    ///[---range-----mid-----range]
    ///MidPoint = Time where it is exact middle of Start ~ begin time.
    ///         = Begin time + Length / 2
    midPoint = (_beginTime.millisecondsSinceEpoch / (60000)) + length / 2;

    ///range = Half of length. It is like radius of circle.
    range = length / 2;
  }
}
