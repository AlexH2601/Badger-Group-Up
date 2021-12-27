import 'dart:async';
import 'package:badger_group_up/src/pages/homescreen/list_view_widget.dart';
import 'package:badger_group_up/src/pages/homescreen/map_view_widget.dart';
import 'package:badger_group_up/src/system/group_manager/group_manager.dart';
import 'package:badger_group_up/src/system/session_manager/activity.dart';
import 'package:badger_group_up/src/system/session_manager/location.dart';
import 'package:badger_group_up/src/system/session_manager/search_filter.dart';
import 'package:badger_group_up/src/system/user.dart';
import 'package:badger_group_up/src/system/route_generator.dart';
import 'package:badger_group_up/src/system/session_manager/session_manager.dart';
import 'package:badger_group_up/src/system/shared_values.dart';
import 'package:badger_group_up/src/widgets/button_factory.dart';
import 'package:badger_group_up/src/widgets/checkbox_factory.dart';
import 'package:badger_group_up/src/widgets/dropdown_factory.dart';
import 'package:badger_group_up/src/widgets/grid_factory.dart';
import 'package:flutter/material.dart';

part 'package:badger_group_up/src/pages/homescreen/home_screen_ui_helper.dart';

///Progress
/// Base UI <--
/// Connect to DB
/// Implement Functions
/// Finish UI overflow
///
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool isMapView = false;
  late Timer _timer;

  void navigateTo(String pageName) async {
    RouteGenerator.pushAndDo(context, pageName, () {
      setState(() {});
    });
  }

  void switchView() {
    isMapView = !isMapView;
    setState(() {});
  }

  void newTimer() {
    reloadDB();
    _timer = Timer(const Duration(seconds: 5), newTimer);
  }

  Future<void> reloadDB() async {
    bool success = await GroupManager.loadGroups();
    if (success) {
      setState(() {});
      success = await SessionManager.instance.loadSessions();
    }
    if (success) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    reloadDB();
    Filter.sessionFilter.reset();
    _timer = Timer(const Duration(seconds: 5), newTimer);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget entryView = (isMapView) ? MapViewWidget() : ListViewWidget();
    var materialApp = MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
                title: const Text('Badger Group Up'),
                backgroundColor: MyTheme.mainColor,
                actions: [
                  IconButton(
                      onPressed: () {
                        navigateTo(RouteGenerator.profile);
                      },
                      icon: const Icon(Icons.account_box)),
                  IconButton(
                      onPressed: () {
                        reloadDB();
                      },
                      icon: const Icon(Icons.refresh)),
                ]),
            body: Stack(
              children: [
                entryView,
                getBottom(),
              ],
            )));
    return materialApp;
  }
}
