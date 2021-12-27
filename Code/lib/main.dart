import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'src/system/route_generator.dart';
import 'src/pages/login/login_page.dart';

void main() {
  runApp(const BadgerGroupUp());
}

void testMode() {
  runApp(const BadgerGroupUp(animatedBackground: false));
}

class BadgerGroupUp extends StatelessWidget {
  const BadgerGroupUp({Key? key, this.animatedBackground = true}) : super(key: key);
  final bool animatedBackground;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Login(animatedBackground: animatedBackground),
        onGenerateRoute: RouteGenerator.generateRoute);
  }
}
