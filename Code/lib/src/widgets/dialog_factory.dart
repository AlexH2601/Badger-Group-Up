import 'package:badger_group_up/src/system/shared_values.dart';
import 'package:badger_group_up/src/widgets/button_factory.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

///Quick tool for pop up dialog
///Direct copy from madrental
class DialogFactory {
  static void popUpMessage(BuildContext context, String title, String content) {


    var dialog = AlertDialog(
      title: Center(child: Text(title)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(child: Text(content)),
        ],
      ),
      actions: <Widget>[
        ButtonFactory.buildOKButton(context),
      ],
    );

    show(context, dialog);
  }

  static void popUpAction(
    BuildContext context,
    String title,
    String content,
    Function onAccept,
    String acceptText) {
    ///Static void PopUpChoice(Context context, string title, string
    // content, Function onDecline, Function onAccept, string
    // declineName, string acceptName)
    // a. Shows the basic dialog with title, content, and two
    // buttons.
    // b. Each button has the text of the given string and call
    // given function on press.
    var dialog = AlertDialog(
      title: Center(child: Text(title)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(child: Text(content)),
        ],
      ),
      actions: <Widget>[
        ButtonFactory.buildCancelButton(context),
        ButtonFactory.buildButton(acceptText, onAccept),
      ],
    );

    show(context, dialog);
  }


  static Future<dynamic> popUpActionContent(
      BuildContext context,
      String title,
      Widget content,
      Function onAccept,
      String acceptText,) async {
    var dialog = AlertDialog(
      title: Center(child: Text(title)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          content,
        ],
      ),
      actions: <Widget>[
        ButtonFactory.buildCancelButton(context),
        ButtonFactory.buildButton(acceptText, onAccept),
      ],
    );

    return showAndWait(context, dialog);
  }


  static void showToast(
      BuildContext context,
      String message) {
    if(MyTheme.isTesting())return;
    debugPrint("TOAST "+message);
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }


  static void show(BuildContext context, AlertDialog dialog) {
    showDialog(
      context: context,
      builder: (BuildContext context) => dialog,
    );
  }
  static Future<dynamic> showAndWait(BuildContext context, AlertDialog dialog) async{
    showDialog(
      context: context,
      builder: (BuildContext context) => dialog,
    );
  }
}
