part of 'package:badger_group_up/src/pages/session_history/session_history_page.dart';

extension CreateSessionHistory on SessionHistoryState {
  Widget getSessionRecordEntryWidget(SessionEntry entry) {
    var deleteButton = IconButton(
        iconSize: 32,
        onPressed: () async {
          debugPrint("Press delete");
          await onPressDeleteHistory(entry);
        },
        icon: const Icon(Icons.delete));

    var activityName =
        Align(alignment: Alignment.centerLeft, child: Text(entry.activity));
    var locationName = Align(
        alignment: Alignment.centerLeft, child: Text(entry.location.name));
    var peopleAndTime = GridFactory.buildEvenRow([
      Center(child: Text(entry.timeToString())),
      Center(
          child: Text(
              '${entry.getCurrentPeopleNumber()} / ${entry.desiredPeople}')),
    ]);

    var infoColumn = Container(
        margin: const EdgeInsets.fromLTRB(10, 10, 0, 10),
        padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
        decoration: BoxDecoration(
            border: Border.all(width: 1),
            //color: MyTheme.subColor,
            borderRadius: const BorderRadius.vertical()),
        child: SingleChildScrollView(child: Column(children: [
          activityName,
          locationName,
          peopleAndTime,
        ])));

    var row = GridFactory.buildRow({
      infoColumn: 7,
      deleteButton: 1,
    });

    var entryRow = SizedBox(
        height: User.screenHeightPixels * 0.2,
        child: Container(
            child: row,
            decoration: BoxDecoration(
                border: Border.all(width: 1),
                //color: MyTheme.subColor,
                borderRadius: GridFactory.getCircularBorder())));

    return entryRow;
  }

  Widget getListView() {
    var list = SessionManager.instance.sessionList;
    List<Widget> widgetList = [];
    for (var entry in list) {
      debugPrint(entry.id+" and "+User.userEmail);
      if(GroupManager.containsUser(entry.id, User.userEmail)){
        widgetList.add(getSessionRecordEntryWidget(entry));
      }
    }
    return ListView(controller: controller, children: widgetList);
  }

  Widget buildBody() {
    return getListView();
  }
}
