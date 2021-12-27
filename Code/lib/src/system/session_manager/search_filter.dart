import 'package:badger_group_up/src/system/session_manager/activity.dart';
import 'package:badger_group_up/src/system/session_manager/location.dart';
import 'package:badger_group_up/src/system/session_manager/session_entry.dart';

///
/// This is an object class holding search values and conditions
/// Used in filtering requests
///
class Filter{
  static Filter sessionFilter = Filter();
  int activity=0;
  int location=0;
  bool searchClosed = false;
  bool searchActivity = false;
  bool searchLocation = false;

  //Resets data to default values
  void reset(){
    searchClosed = false;
    searchActivity = false;
    searchLocation = false;
  }

  bool runFilter(SessionEntry entry){
    bool loc = !searchLocation;
    bool act = !searchActivity;
    bool tim = !searchClosed;
    if(searchActivity){
      if(entry.activity == Activity.activities[activity]) act =  true;
      if(entry.description.contains(Activity.activities[activity])) act =  true;
    }
    //AND search
    if(searchLocation){
      if(entry.location.id == Location.locations[location].id) loc =  true;
    }
    if(searchClosed){
      tim = true;
    }else{
      tim =  entry.isJoinable("");
    }
    return loc && act && tim;
  }

  String summarise(){
    String a = "";
    if(searchActivity){
      a+="Act: "+ Activity.activities[activity];
    }
    if(searchLocation){
      a+="Location: "+ Location.locations[location].name;
    }
    return a;
  }

}