import 'package:badger_group_up/src/system/user.dart';
import 'package:badger_group_up/src/system/shared_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';

class TimePickerFactory{
  static Widget buildTimePicker(DateTime initValue, Function onChange) {
    return TimePickerSpinner(
      itemWidth: 0.1*User.screenWidthPixels,
      time: initValue,
      normalTextStyle: const TextStyle(
        fontSize: 20,
        //      color: MyTheme.mainColor,
      ),
      is24HourMode: false,
      minutesInterval: 15,
      highlightedTextStyle: TextStyle(
        fontSize: 24,
        color: MyTheme.subColor,
      ),
      spacing: 50,
      itemHeight: 50,
      isForce2Digits: true,
      onTimeChange: (time) {
        onChange(time);
      },
    );
  }

}