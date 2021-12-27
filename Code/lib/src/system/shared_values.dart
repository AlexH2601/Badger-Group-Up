import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

///This file stores miscellanoues values that is used anywhere
///Like Enum class
///
enum  SessionStatus{
  Open,Closed,Done
}
extension StatusToString on SessionStatus {
  String getName() {
    switch(this){
      case SessionStatus.Open:
        return "Open";
      case SessionStatus.Closed:
        return "Closed";
      case SessionStatus.Done:
        return "Done";
    }
  }
}
enum SkillLevel{
  NoPreference,Casual,Intermediate,Advanced
}
///
/// skillLevel.toShortString() returns corresponding string value
/// but you must import this file to use this function(it is like a class?)
///
extension SkillToString on SkillLevel {
  String getName() {
    switch(this){
      case SkillLevel.NoPreference:
        return 'No Preference';
      case SkillLevel.Casual:
        return 'Casual';
      case SkillLevel.Intermediate:
        return 'Intermediate';
      case SkillLevel.Advanced:
        return 'Advanced';
    }
  }
}

enum Relation{
  User,Session,Group
}
extension RelationToString on Relation {
  String getName() {
    switch(this){
      case Relation.User:
        return 'User';
      case Relation.Session:
        return 'Session';
      case Relation.Group:
        return 'Group';
    }
  }
}
///Use color from here
///So colors can be changed at once.
class MyTheme{
  static final Color? mainColor = Colors.red[400];
  static final Color? subColor = Colors.amber[800];
  static final Color? disabledColor = Colors.grey[500];

  //Quick print on time
  //For debugPrint
  //Because default toString prints too many info
  static String printTime(DateTime time)=>
      DateFormat('MMMM dd – h:mm a').format(time);
  static String printTimeShort(DateTime time)=>
      DateFormat('h:mm a').format(time);
  static bool isTesting()=>Platform.environment.containsKey('FLUTTER_TEST');

}

