part of 'package:badger_group_up/src/system/session_manager/session_manager.dart';
extension SessionManagerUI on SessionManager {

  Widget buildSessionDialog(
      BuildContext? context, SessionEntry entry){

    var locationText = Text(entry.location.name);
    var activityText = Text(entry.activity.toString());
    var timeText = Text(entry.timeToString());
    var skill = Text(entry.skillLevel.getName());
    var people = Text(entry.peopleToString());
    var skillpeoplebox = GridFactory.buildEvenRow([skill, people]);
    var descriptionText = Text(entry.description);
    var col =
    (MyTheme.isTesting())?Container(): GridFactory.buildColumn({
      locationText: 1,
      activityText: 1,
      timeText: 1,
      skillpeoplebox: 1,
      descriptionText: 5
    });

    var box = SizedBox(
      width: User.screenWidthPixels * 0.85,
      height: User.screenHeightPixels * 0.5,
      child: col,
    );

    var cancelButton = ElevatedButton(
      style: ElevatedButton.styleFrom(primary: MyTheme.mainColor),
      child: const Text("Cancel"),
      onPressed: () {
        if(context != null){
          Navigator.of(context, rootNavigator: true).pop(false);
        }
      },
    );
    bool canJoin = entry.isJoinable(User.userEmail);
    var joinButton =
    ButtonFactory.buildButtonConditional("Join", canJoin, () async {
      bool needReload = await GroupManager.joinGroup(entry.id);
      if (needReload && context != null) {
        Navigator.of(context, rootNavigator: true).pop(true);
      }
    });

    var dialog = AlertDialog(
      title: const Center(child: Text('Detail')),
      content: box,
      actions: <Widget>[cancelButton, joinButton],
    );
    return dialog;

  }

  Future<bool?> showSessionDetail(
      BuildContext context, SessionEntry entry) async {
    var dialog = buildSessionDialog(context, entry);
    return await showDialog(context: context, builder: (context) => dialog);
  }

}