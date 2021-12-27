import 'package:badger_group_up/src/system/group_manager/group_manager.dart';
import 'package:badger_group_up/src/system/route_generator.dart';
import 'package:badger_group_up/src/system/session_manager/session_entry.dart';
import 'package:badger_group_up/src/system/session_manager/session_manager.dart';
import 'package:badger_group_up/src/system/shared_values.dart';
import 'package:badger_group_up/src/system/user.dart';
import 'package:badger_group_up/src/widgets/button_factory.dart';
import 'package:badger_group_up/src/widgets/dialog_factory.dart';
import 'package:badger_group_up/src/widgets/grid_factory.dart';
import 'package:flutter/material.dart';

part 'package:badger_group_up/src/pages/session_history/session_history_ui_helper.dart';
///Progress
/// Base UI <--
/// Connect to DB
/// Implement Functions
/// Finish UI overflow
///

class SessionHistory extends StatefulWidget {
  const SessionHistory({Key? key}) : super(key: key);

  @override
  SessionHistoryState createState() => SessionHistoryState();
}

class SessionHistoryState extends State<SessionHistory> {
  final controller = ScrollController();


  Future<void> onPressDeleteHistory(SessionEntry entry) async {
    bool reload = await GroupManager.loadGroups();
    if(!reload) return;
    if(GroupManager.getNumberOfPeopleInSession(entry.id) <= 1){
      DialogFactory.popUpAction(context,
          "You are the last one", "If you leave this session, the session will be disbanded",
          ()async {
            leaveSession(entry.id);
            RouteGenerator.pop(context);
          }, "Leave");

    }else{
      leaveSession(entry.id);
    }
  }
 Future<void> leaveSession(String id) async {
   bool success = await GroupManager.removeFromGroup(id);
   if(success){
     setState((){});
   }
 }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(backgroundColor: MyTheme.mainColor,
              titleSpacing: 0,
              title: Row(children: [ButtonFactory.buildExitIcon(context), const Text('Beacon History')]),
            ),
            body: buildBody()));
  }
}
