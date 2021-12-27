import 'package:flutter/material.dart';

///Quick generation of checkbox
///
class CheckboxFactory {
  static Checkbox buildCheckBoxColor(Color checkColor, Color fillColor,
      bool defaultValue, Function onChangedAction_boolParam) {
    return Checkbox(
        checkColor: checkColor,
        fillColor:
            MaterialStateProperty.resolveWith((Set<MaterialState> states) {
          return fillColor;
        }),
        value: defaultValue,
        onChanged: (value) {
          onChangedAction_boolParam(value);
        });
  }

  static Checkbox buildCheckBox(bool defaultValue, Function onChangedAction_boolParam) {
    return buildCheckBoxColor(
        Colors.white, Colors.black, defaultValue, onChangedAction_boolParam);
  }
}
