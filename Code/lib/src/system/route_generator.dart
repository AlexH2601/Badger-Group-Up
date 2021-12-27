import 'package:badger_group_up/src/pages/create_session/create_session_page.dart';
import 'package:badger_group_up/src/pages/homescreen/home_screen_page.dart';
import 'package:badger_group_up/src/pages/profile_page/profile_page.dart';
import 'package:badger_group_up/src/pages/session_history/session_history_page.dart';
import 'package:flutter/material.dart';
import '../pages/login/login_page.dart';

class RouteGenerator {
  static const String loginPage = "Login";
  static const String mainMenu = "Main Menu";
  static const String createSession = "Create Session";
  static const String profile = "Profile";
  static const String sessionHistory = "Session History";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginPage:
        return MaterialPageRoute(builder: (_) => const Login());
      case mainMenu:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case createSession:
        return MaterialPageRoute(builder: (_) => const CreateSession());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case sessionHistory:
        return MaterialPageRoute(builder: (_) => const SessionHistory());
    }
    return MaterialPageRoute(builder: (_) => const Login());
  }

  ///Unified way to execute Quit
  static void pop(BuildContext context) {
    Navigator.of(context).pop();
  }

  ///Unified way to execute Quit with param
  ///UNUSED
/*  static void popParam(BuildContext context, Object? result) {
    Navigator.of(context).pop(result);
  }*/

  ///Unified way to push and Wait And Do something
  static void pushAndDo(
      BuildContext context, String pageName, Function thenDo) {
    Navigator.of(context).pushNamed(pageName).then((result) {
      thenDo();
    });
  }
  ///Unified way to push and Wait And Do something with param
  ///UNUSED
 /* static void pushAndDoWith(
      BuildContext context, String pageName, Function thenDo) {
    Navigator.of(context).pushNamed(pageName).then((result) {
      thenDo(result);
    });
  }*/
  ///Unified way to push.
  static void push(BuildContext context, String pageName, Function thenDo) {
    Navigator.of(context).pushNamed(pageName);
  }
}
