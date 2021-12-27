import 'package:badger_group_up/src/system/session_manager/search_filter.dart';
import 'package:badger_group_up/src/system/session_manager/session_entry.dart';
import 'package:badger_group_up/src/system/session_manager/session_manager.dart';
import 'package:badger_group_up/src/system/shared_values.dart';
import 'package:badger_group_up/src/system/user.dart';
import 'package:badger_group_up/src/widgets/grid_factory.dart';
import 'package:flutter/material.dart';

class ListViewWidget extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  ListViewWidget({Key? key}) : super(key: key);

  @override
  ListViewWidgetState createState() => ListViewWidgetState();
}

class ListViewWidgetState extends State<ListViewWidget> {
  final controllers = ScrollController();

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = [];
    for (var entry in SessionManager.instance.sessionList) {
      if(Filter.sessionFilter.runFilter(entry)){
        widgetList.add(getSessionEntryWidget(context, entry));
      }
    }
    return Column(children: [
      Expanded(
          flex: 8,
          child: Directionality(
              textDirection: TextDirection.ltr,
              child: ListView(controller: controllers, children: widgetList))),
      Expanded(flex: 1, child: Container()),
    ]);
  }

  Future<void> onPressJoinButton(SessionEntry entry) async{
    bool? needReload =await SessionManager.instance.showSessionDetail(context, entry);
    if (needReload != null && needReload) {
      setState(() {});
    }
  }

  Widget getJoinButton(SessionEntry entry) {
    String text;
    Color? color;
    if (entry.isFull()) {
      color = MyTheme.disabledColor;
      text = "Full\n" + entry.peopleToString();
    } else if (entry.isExpired()) {
      color = MyTheme.disabledColor;
      text = "Ended\n" + entry.peopleToString();
    } else if (entry.containsUser(User.userEmail)) {
      //  color = MyTheme.subColor;
      text = "Joined\n" + entry.peopleToString();
    } else {
      text = entry.peopleToString();
    }

    var button = ElevatedButton(
      child: Text(text),
      onPressed: () async {
        await onPressJoinButton(entry);
      },
      style: ElevatedButton.styleFrom(
          primary: color,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          )),
    );

    return button;
  }

  Widget getSessionEntryWidget(BuildContext context, SessionEntry entry) {
    var iconOfActivity = const Icon(Icons
        .verified_sharp);
    var locationText = Text(entry.location.name);
    var activityName = Text(entry.activity
    ,  style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ); //entry.nameOfActivity);
    var timeText = Text(entry.timeToString(),

    ); //Text('${entry.beginTime.toString()} ~ ${entry.endTime.toString()}');

    var joinButton = getJoinButton(entry);
    var subBlock1 =
    Container(
      padding: const EdgeInsets.fromLTRB(0,25,0,0),
      child:
      GridFactory.buildEvenColumn([locationText, activityName,],mainAxis:MainAxisAlignment.spaceEvenly )
    );

    //Icon and Activity block
    var subBlock2 = GridFactory.buildRow({
      iconOfActivity: 1,
      subBlock1: 4,
    });

    //Icon and Time block
    var subBlock3 = GridFactory.buildColumn({
      subBlock2: 4,
      timeText: 1,
    });

    //Time and people block
    var subBlock4 = GridFactory.buildRow({
      subBlock3: 8,
      joinButton: 3,
    });

    double padding = 0.005 * User.screenWidthPixels;
    var block = Container(
        padding: EdgeInsets.all(padding),
        child: SizedBox(
            width: User.screenWidthPixels * 0.8,
            height: User.screenHeightPixels * 0.2,
            child: Container(
                padding: EdgeInsets.fromLTRB(0, padding, 0, padding),
                decoration: BoxDecoration(
                  border: Border.all(width: 1),
                  // color: MyTheme.subColor,
                  borderRadius: GridFactory.getCircularBorder(),
                ),
                child: subBlock4)));
    return block;
  }
}
