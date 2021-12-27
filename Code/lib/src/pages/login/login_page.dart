import 'package:badger_group_up/src/system/save_manager.dart';
import 'package:badger_group_up/src/system/user.dart';
import 'package:flutter/material.dart';

import 'sign_in_page.dart';
import 'register_page.dart';

class Login extends StatefulWidget {
  const Login({Key? key, this.animatedBackground = true}) : super(key: key);
  final bool animatedBackground;

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _init = true;
  final PageController _controller = PageController(initialPage: 0);


  @override
  void initState(){
    super.initState();
    SaveManager.instance.loadPrefs();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_init) {
      _init = false;
      User.animatedBackground = widget.animatedBackground;
      MediaQueryData device = MediaQuery.of(context);
      User.screenWidthPixels = device.size.width;
      User.screenHeightPixels = device.size.height;
    }
    return PageView(controller: _controller, children: [SignIn(animatedBackground: widget.animatedBackground), Register(animatedBackground: widget.animatedBackground)]);
  }
}