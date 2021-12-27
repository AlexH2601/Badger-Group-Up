import 'package:badger_group_up/src/system/shared_values.dart';
import 'package:flutter/material.dart';

///Quick generation of DropDown
///Provide list and function to execute on press.
///Provided function need (int index) as a parameter
class DropDownFactory {
  static DropdownButton<int> buildDropdown(
      List<dynamic> list, Function onChangedAction,
      {int defaultIndex = 0}) {
    List<DropdownMenuItem<int>> dropdown = [];
    for (int i = 0; i < list.length; i++) {
      var item = DropdownMenuItem<int>(
        value: (i),
        child: Text(list[i].toString()),
      );
      dropdown.add(item);
    }

    var widget = DropdownButton<int>(
      value: defaultIndex,
      isExpanded: true,
      icon: const Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: MyTheme.subColor),
      underline: Container(
        height: 2,
        color: MyTheme.subColor,
      ),
      onChanged: (int? newValue) {
        onChangedAction(newValue);
      },
      items: dropdown,
    );
    return widget;
  }

  static DropdownButton<int> buildDropdownEnum(List<dynamic> list,
      Function onChangedAction, List<DropdownMenuItem<int>> dropdown
      ,{int defaultIndex = 0}
      ) {
    var widget = DropdownButton<int>(
      value: defaultIndex,
      isExpanded: true,
      icon: const Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: MyTheme.subColor),
      underline: Container(
        height: 2,
        color: MyTheme.subColor,
      ),
      onChanged: (int? newValue) {
        onChangedAction(newValue);
      },
      items: dropdown,
    );
    return widget;
  }
}
