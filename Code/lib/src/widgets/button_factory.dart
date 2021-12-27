import 'package:badger_group_up/src/system/shared_values.dart';
import 'package:flutter/material.dart';

///Quick build buttons
///(but why)
/// These buttons only allow Function with no parameter.
///
///
class ButtonFactory {
  static ElevatedButton buildButton(String text, Function action) {
    return ElevatedButton(
      child: Text(text),
      onPressed: (){action();},
    );
  }  static ElevatedButton buildButtonStyle(String text, Function action, ButtonStyle bStyle) {
    return ElevatedButton(
      child: Text(text),
      style: bStyle,
      onPressed: (){action();},
    );
  }

  static IconButton buildIcon(IconData icon, Function action) {
    return IconButton(

        onPressed: action(), icon: Icon(icon));
  }
  static IconButton buildExitIcon(BuildContext context){
    return IconButton(
        iconSize: 32,
        splashColor: MyTheme.subColor,
        onPressed: () {Navigator.pop(context);}, icon: const Icon(Icons.arrow_back));
  }
  static Widget buildCancelButton(BuildContext context) {
    return ElevatedButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  static Widget buildOKButton(BuildContext context) {
    return ElevatedButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }


  static Widget buildButtonConditional(String text, bool condition, Function positiveAction, {
    Function? negativeAction
}) {
    var button = ElevatedButton(
      child: Text(text),
      onPressed: () {
        if (condition) {
          positiveAction();
        }else{
          if(negativeAction != null) negativeAction();
        }
      },
      style: ElevatedButton.styleFrom(
          primary: (condition) ? MyTheme.mainColor:MyTheme.disabledColor ,
          textStyle: TextStyle(
            fontSize: 18,
            fontWeight: (condition) ?FontWeight.normal:  FontWeight.bold ,
          )),
    );
    return button;
  }
}
