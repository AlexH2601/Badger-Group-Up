import 'package:flutter/material.dart';
import 'package:animated_background/animated_background.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:badger_group_up/src/system/database.dart';
import 'package:badger_group_up/src/system/route_generator.dart';
import 'package:badger_group_up/src/system/user.dart';
import 'package:badger_group_up/src/system/email_auth.dart';
import 'package:flutter/services.dart';

class Register extends StatefulWidget {
  const Register({Key? key, this.animatedBackground = true}) : super(key: key);
  final bool animatedBackground;

  @override
  RegisterState createState() => RegisterState();
}

class RegisterState<T extends Register> extends State<T> with TickerProviderStateMixin {
  bool loadingDB = false;
  bool error = false;
  String errorMessage = '';
  late EmailAuthentication emailAuth;
  TextEditingController otp = TextEditingController();
  final Map<String, TextEditingController> registerTextControllers = {
    'email': TextEditingController(),
    'firstName': TextEditingController(),
    'lastName': TextEditingController(),
    'pass': TextEditingController(),
    'passConfirm': TextEditingController(),
  };

  // Attempt to create new user in database
  dynamic registerDB(String creationDate) async {
    Map<String, String> dbValues = {
      'email': sha256.convert(utf8.encode(registerTextControllers['email']!.text.toLowerCase().trim())).toString(),
      'firstName': registerTextControllers['firstName']!.text,
      'lastName': registerTextControllers['lastName']!.text,
      'password': sha256.convert(utf8.encode(registerTextControllers['pass']!.text)).toString(),
      'date': creationDate
    };
    if (await Database.instance.insert('User', dbValues)) {
      // Assign user globals
      Map<String, String> userValues = {
      'email': registerTextControllers['email']!.text,
      'firstName': registerTextControllers['firstName']!.text,
      'lastName': registerTextControllers['lastName']!.text,
      'creationDate': creationDate
      };
      if (User.loadUserInfo(userValues)) {
      debugPrint('User: ' + User.userEmail + ' | ' + User.firstName + ' ' + User.lastName + ' | ' + User.creationDate);
      Navigator.of(context).popAndPushNamed(RouteGenerator.mainMenu);
      }
      else {
      return false;
      }
    }
    else {
      setState(() {createError('An account with that email already exists.');});
      return false;
    }
  }

  otpDialog() {
    Container otpField = Container(child: TextField(controller: otp,
                                                    decoration: const InputDecoration(labelText: 'Enter the OTP sent to your email'),
                                                    keyboardType: TextInputType.number,
                                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly]));

    Widget cancelButton = TextButton(
      child: const Text('Cancel'),
      onPressed:  () {setState(() {loadingDB = false; Navigator.pop(context);});},
    );

    Widget continueButton = TextButton(
      child: const Text('Submit'),
      onPressed:  () {if (emailAuth.validateOTP(registerTextControllers['email']!.text.toLowerCase().trim(), otp.text)) {
                        registerDB(DateTime.now().toString());
                        Navigator.pop(context);
                      }
                      else {
                        setState(() {Navigator.pop(context); createError('Incorrect OTP.');});
                      }
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text('Email Verification'),
      content: otpField,
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // Send authentication email
  dynamic createEmailAuth() async {
    emailAuth = EmailAuthentication('Badger Group Up');
    if (await emailAuth.sendAuthEmail(registerTextControllers['email']!.text.toLowerCase().trim())) {
        otpDialog();
      }
    else {
      setState(() {createError('Sorry, a server error occurred.');});
      return false;
    }
  }

  // Do some basic checks on user credentials
  bool verifyUserInfo() {
    // Check if all fields filled out
    for (TextEditingController controller in registerTextControllers.values) {
      if (controller.text.isEmpty) {
        setState(() {createError('Please fill out all fields.');});
        return false;
      }
    }

    // Check if the email has the wisc format
    if (!registerTextControllers['email']!.text.contains('@wisc.edu')) {
      setState(() {createError('Please use your wisc.edu email.');});
      return false;
    }

    // Check for >=3 password length
    if (registerTextControllers['pass']!.text.length < 3) {
      setState(() {createError('Please use a 3+ character password.');});
      return false;
    }

    // Check for password match
    if (registerTextControllers['pass']!.text != registerTextControllers['passConfirm']!.text) {
      setState(() {createError('Passwords do not match.');});
      return false;
    }

    createEmailAuth();
    return true;
  }

  // Helper method to create an error
  void createError(String message) {
    loadingDB = false;
    error = true;
    errorMessage = message;
  }

  @override
  Widget build(BuildContext context) {
    // Vertical widget to hold the page
    Column form;

    Text title = const Text('Register Now!');

    // TextFields to get user input
    Container email = Container(width: 0.4*User.screenWidthPixels, child: TextField(controller: registerTextControllers['email'],
                                                                                    decoration: const InputDecoration(labelText: 'Email')));
    Container firstName = Container(width: 0.4*User.screenWidthPixels, child: TextField(controller: registerTextControllers['firstName'],
                                                                                        decoration: const InputDecoration(labelText: 'First Name')));
    Container lastName = Container(width: 0.4*User.screenWidthPixels, child: TextField(controller: registerTextControllers['lastName'],
                                                                                        decoration: const InputDecoration(labelText: 'Last Name')));
    Container password = Container(width: 0.4*User.screenWidthPixels, child: TextField(controller: registerTextControllers['pass'],
                                                                                        decoration: const InputDecoration(labelText: 'Password'), obscureText: true));
    Container passwordConfirm = Container(padding: const EdgeInsets.only(bottom: 10), width: 0.4*User.screenWidthPixels, child: TextField(controller: registerTextControllers['passConfirm'],
                                                                                                                                          decoration: const InputDecoration(labelText: 'Confirm Password'), obscureText: true));
    ElevatedButton submit = ElevatedButton(onPressed: loadingDB ? () {} : () {setState(() {loadingDB = true; verifyUserInfo();});}, style: loadingDB ? ElevatedButton.styleFrom(primary: Colors.grey) : ElevatedButton.styleFrom(primary: Colors.blue), child: const Text("Register"));
    Container paddedSubmit = Container(padding: const EdgeInsets.only(bottom: 10), child: submit);

    // Text to inform user how to switch between sign in and registration pages
    Text switchPage = const Text("<<< Swipe to Sign in");

    form = Column(mainAxisAlignment: MainAxisAlignment.center, children: [title, email, firstName, lastName, password, passwordConfirm, error ? Text(errorMessage, style: const TextStyle(color: Colors.red)) : Container(),
                                                                          paddedSubmit, switchPage]);

    if (widget.animatedBackground) {
      return WillPopScope(onWillPop: () async => false, child: MaterialApp(debugShowCheckedModeBanner: false,
          home: Scaffold(resizeToAvoidBottomInset: false,
              body: AnimatedBackground(behaviour: RandomParticleBehaviour(options: const ParticleOptions(particleCount: 50, spawnMinRadius: 5, spawnMaxRadius: 13, spawnMinSpeed: 100, spawnMaxSpeed: 200, minOpacity: 0.3, maxOpacity: 0.6, image: Image(image: AssetImage("assets/bucky.png")))), vsync: this,
                  child: Stack(children:
                  [Center(child: form)]
              )))
      ));
    }
    else {
      return MaterialApp(debugShowCheckedModeBanner: false,
          home: Scaffold(resizeToAvoidBottomInset: false,
              body: Stack(children:
              [Center(child: form)]
              ))
      );
    }
  }
}