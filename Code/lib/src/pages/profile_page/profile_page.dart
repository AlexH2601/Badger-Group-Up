import 'package:badger_group_up/src/system/group_manager/group_manager.dart';
import 'package:badger_group_up/src/pages/login/login_page.dart';
import 'package:badger_group_up/src/system/shared_values.dart';
import 'package:badger_group_up/src/system/user.dart';
import 'package:badger_group_up/src/widgets/button_factory.dart';
import 'package:badger_group_up/src/widgets/dialog_factory.dart';
import 'package:badger_group_up/src/system/database.dart';

import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

part 'package:badger_group_up/src/pages/profile_page/profile_ui_helper.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {

  final Map<String, TextEditingController> passwordTextControllers = {
    'newPassword': TextEditingController(), //Controller for resetting password
  };

  @override
  Widget build(BuildContext context) {

    var logout =  IconButton(
        iconSize: 32,
        splashColor: MyTheme.subColor,
        onPressed: () {
          User.logout();
          while(Navigator.of(context).canPop()){
            Navigator.of(context).pop();
          }
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => Login(animatedBackground: User.animatedBackground)));
        }, icon: const Icon(Icons.logout));
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            resizeToAvoidBottomInset: false,
           appBar: AppBar(backgroundColor: MyTheme.mainColor,
               titleSpacing: 0,
               title: Row(children: [ButtonFactory.buildExitIcon(context), const Text('My Profile')]),
               actions: [logout]),
            body: buildBody()
        )
    );
  }
}
