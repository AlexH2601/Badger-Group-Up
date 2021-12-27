import 'package:flutter/material.dart';

///
/// Quick build evenly spaced rows and columns
///
class GridFactory {
  static Widget buildEvenRow(
    List<Widget> list, {
    MainAxisAlignment mainAxis = MainAxisAlignment.spaceEvenly,
    CrossAxisAlignment crossAxis = CrossAxisAlignment.center,
  }) {
    var row = Row(
      crossAxisAlignment: crossAxis,
      mainAxisAlignment: mainAxis,
      children: [],
    );
    for (var v in list) {
      var e = Expanded(flex: 1, child: v);
      row.children.add(e);
    }
    return row;
  }

  static Widget buildEvenColumn(
    List<Widget> list, {
    MainAxisAlignment mainAxis = MainAxisAlignment.spaceEvenly,
    CrossAxisAlignment crossAxis = CrossAxisAlignment.center,
  }) {
    var col = Column(
      crossAxisAlignment: crossAxis,
      mainAxisAlignment: mainAxis,
      children: [],
    );
    for (var v in list) {
      var e = Expanded(flex: 1, child: v);
      col.children.add(e);
    }
    return col;
  }

  static Widget buildColumn(
    Map<Widget, int> list, {
    MainAxisAlignment mainAxis = MainAxisAlignment.spaceEvenly,
    CrossAxisAlignment crossAxis = CrossAxisAlignment.center,
  }) {
    var col = Column(
      crossAxisAlignment: crossAxis,
      mainAxisAlignment: mainAxis,
      children: [],
    );

    list.forEach((key, value) {
      var e = Expanded(flex: value, child: key);
      col.children.add(e);
    });
    return col;
  }

  static Widget buildRow(
    Map<Widget, int> list, {
    MainAxisAlignment mainAxis = MainAxisAlignment.spaceEvenly,
    CrossAxisAlignment crossAxis = CrossAxisAlignment.center,
  }) {
    var row = Row(
      crossAxisAlignment: crossAxis,
      mainAxisAlignment: mainAxis,
      children: [],
    );

    list.forEach((key, value) {
      var e = Expanded(flex: value, child: key);
      row.children.add(e);
    });
    return row;
  }

  static BorderRadius getCircularBorder(){
   return const BorderRadius.only(
        topLeft: Radius.circular(1),
    topRight: Radius.circular(1),
    bottomLeft: Radius.circular(1),
    bottomRight: Radius.circular(20),
   );
  }
}
