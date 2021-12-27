import 'package:badger_group_up/src/system/save_manager.dart';
import 'package:badger_group_up/src/widgets/checkbox_factory.dart';
import 'package:badger_group_up/src/widgets/dialog_factory.dart';
import 'package:flutter/material.dart';
import 'package:animated_background/animated_background.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:badger_group_up/src/system/database.dart';
import 'package:badger_group_up/src/system/route_generator.dart';
import 'package:badger_group_up/src/system/user.dart';
import 'package:badger_group_up/src/system/email_auth.dart';
import 'package:badger_group_up/src/system/shared_values.dart';
import 'package:flutter/services.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key, this.animatedBackground = true}) : super(key: key);
  final bool animatedBackground;

  @override
  SignInState createState() => SignInState();
}

class SignInState<T extends SignIn> extends State<T> with TickerProviderStateMixin {
  bool loadingDB = false;
  bool error = false;
  String errorMessage = '';
  late EmailAuthentication emailAuth;
  TextEditingController otp = TextEditingController();
  final Map<String, TextEditingController> loginTextControllers = {
    'email': TextEditingController(),
    'pass': TextEditingController()
  };

  // Check database for user credentials
  dynamic loginDB() async {
    Map<String, String> dbValues = {
      "email": sha256.convert(utf8.encode(loginTextControllers['email']!.text.toLowerCase())).toString(),
      "password": sha256.convert(utf8.encode(loginTextControllers['pass']!.text)).toString()
    };

    List<List<dynamic>> dbResponse = await Database.instance.select('User', conditionals: dbValues);

    if (dbResponse.isEmpty) {
      setState(() {createError('Incorrect email or password.');});
      return false;
    }
    else {
      // Assign user globals
      Map<String, String> userValues = {
        'email': loginTextControllers['email']!.text.toLowerCase(),
        'firstName': dbResponse[0][1],
        'lastName': dbResponse[0][2],
        'creationDate': dbResponse[0][4].toString()
      };
      if (User.loadUserInfo(userValues)) {
        debugPrint('User: ' + User.userEmail + ' | ' + User.firstName + ' ' + User.lastName + ' | ' + User.creationDate);
        Navigator.of(context).popAndPushNamed(RouteGenerator.mainMenu);
      }
      else {
      }
    }
  }

  // Do some basic checks on user credentials
  dynamic verifyUserInfo() {
    // Check if user has filled the fields out
    if (loginTextControllers['email']!.text.isEmpty) {
      setState(() {createError('Please enter your wisc.edu email.');});
      return false;
    }
    else if (loginTextControllers['pass']!.text.isEmpty) {
      setState(() {createError('Please enter your password.');});
      return false;
    }

    // Check if the user's input email is a wisc email
    if (!loginTextControllers['email']!.text.contains('@wisc.edu')) {
      setState(() {createError('Please sign in with your wisc.edu email.');});
      return false;
    }

    // Check if the password is of correct length
    if (loginTextControllers['pass']!.text.length < 3) {
      setState(() {createError('Please enter the correct 3+ character password.');});
      return false;
    }
    saveAutoLogin();
    loginDB();
    return true;
  }

  emailDialog() {
    Container emailField = Container(child: TextField(controller: loginTextControllers['email'],
        decoration: const InputDecoration(labelText: 'Enter your email.')));

    Container passField = Container(child: TextField(controller: loginTextControllers['pass'],
        decoration: const InputDecoration(labelText: 'Enter your new password.'), obscureText: true));

    Widget cancelButton = TextButton(
      child: const Text('Cancel'),
      onPressed:  () {Navigator.pop(context);},
    );

    Widget continueButton = TextButton(
      child: const Text('Submit'),
      onPressed:  () async {
        if (loginTextControllers['email']!.text.contains('@wisc.edu')) {
          if (loginTextControllers['pass']!.text.length < 3) {
            Navigator.pop(context);
            DialogFactory.popUpMessage(context, 'Error', 'Please use a 3+ character password.');
            return;
          }

          if ((await Database.instance.select('User', conditionals: {
            'email': sha256.convert(utf8.encode(loginTextControllers['email']!.text.toLowerCase())).toString()
          })).isNotEmpty) {
            Navigator.pop(context);
            emailAuth = EmailAuthentication('Badger Group Up');
            if (await emailAuth.sendAuthEmail(
                loginTextControllers['email']!.text.toLowerCase().trim())) {
              otpDialog();
            }
            else {
              Navigator.pop(context);
              DialogFactory.popUpMessage(context, 'Error', 'Sorry, a server error occurred.');
            }
          }
          else {
            Navigator.pop(context);
            DialogFactory.popUpMessage(context, 'Error', 'There is no account with that email.');
          }
        }
        else {
          Navigator.pop(context);
          DialogFactory.popUpMessage(context, 'Error', 'Please input a valid email address.');
        }
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text('Reset Password'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [emailField, passField]),
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

  otpDialog() {
    Container otpField = Container(child: TextField(controller: otp,
        decoration: const InputDecoration(labelText: 'Enter the OTP sent to your email'),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly]));

    Widget cancelButton = TextButton(
      child: const Text('Cancel'),
      onPressed:  () {otp.text = ''; Navigator.pop(context);},
    );

    Widget continueButton = TextButton(
      child: const Text('Submit'),
      onPressed:  () async {
        if (emailAuth.validateOTP(loginTextControllers['email']!.text.toLowerCase().trim(), otp.text)) {
          if (await Database.instance.update('User', {'password': sha256.convert(utf8.encode(loginTextControllers['pass']!.text.toLowerCase())).toString()}, {'email': sha256.convert(utf8.encode(loginTextControllers['email']!.text.toLowerCase())).toString()})) {
            Navigator.pop(context);
            otp.text = '';
            DialogFactory.popUpMessage(context, 'Success!', 'Your password has been changed.');
          }
          else {
            Navigator.pop(context);
            otp.text = '';
            DialogFactory.popUpMessage(context, 'Error', 'Sorry, a server error occurred.');
          }
        }
        else {
          Navigator.pop(context);
          otp.text = '';
          DialogFactory.popUpMessage(context, 'Error', 'Incorrect OTP.');
        }
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text('Reset Password'),
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

  // Helper method to create an error
  void createError(String message) {
    loadingDB = false;
    error = true;
    errorMessage = message;
  }

  bool actuallyDoAutoLogIn = false;
  bool autoLoginEnabled = false;
  void onCheckSaveCredentials(bool value){
    autoLoginEnabled= value;
    SaveManager.instance.saveBool("IsCredentialSaved", autoLoginEnabled);
    setState((){
    });
  }
  @override
  void initState() {
    super.initState();
    loadAutoLogin();
  }
  dynamic loadAutoLogin() async {
    autoLoginEnabled = await SaveManager.instance.loadBool("IsCredentialSaved", def:false);
    if(autoLoginEnabled){
      var id = await SaveManager.instance.loadString("myId");
      var pass = await SaveManager.instance.loadString("myCode");
      if(id!= null){
        loginTextControllers['email']!.text = id;
      }
      if(pass!= null){
        loginTextControllers['pass']!.text = pass;
      }
      setState((){});
      if(actuallyDoAutoLogIn)verifyUserInfo();
    }
  }
  void saveAutoLogin(){
    if(!autoLoginEnabled) return;
    var id = loginTextControllers['email']!.text;
    var pass = loginTextControllers['pass']!.text;
    SaveManager.instance.saveString("myId", id);
    SaveManager.instance.saveString("myCode", pass);
  }


  @override
  Widget build(BuildContext context) {
    // Vertical widget to hold the page
    Column form;

    Text title = const Text('Sign In!');

    // TextFields to get user input
    TextField email = TextField(controller: loginTextControllers['email'],
                                decoration: const InputDecoration(labelText: 'Email'));
    TextField password = TextField(controller: loginTextControllers['pass'],
                                    decoration: const InputDecoration(labelText: 'Password'),
                                    obscureText: true);

    // Containers to limit the width of the TextFields (i.e. prevent from taking up the whole screen)
    Container sizedEmail = Container(width: 0.4*User.screenWidthPixels, child: email);
    Container sizedPassword = Container(padding: const EdgeInsets.only(bottom: 10), width: 0.4*User.screenWidthPixels, child: password);

    // Button to submit entered info
    ElevatedButton submit = ElevatedButton(onPressed: loadingDB ? () {} : () {setState(() {loadingDB = true; verifyUserInfo();});},
                                            style: loadingDB ? ElevatedButton.styleFrom(primary: Colors.grey) : ElevatedButton.styleFrom(primary: Colors.blue), child: const Text("Sign In"));
    Container submitPadded = Container(child: submit);

    // TextButton to reset password
    TextButton forgotPassword = TextButton(onPressed: () {emailDialog();}, style: const ButtonStyle(splashFactory: NoSplash.splashFactory), child: const Text('Forgot Password?', style: TextStyle(color: Colors.blue)));

    // Save credentials
    Text saveCredentialText = const Text("Save credentials");
    Checkbox autoLogin = CheckboxFactory.buildCheckBox(autoLoginEnabled, onCheckSaveCredentials);
    var savedLoginRow = Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children:[saveCredentialText,autoLogin]);
    Container paddedCredentials = Container(padding: const EdgeInsets.only(bottom: 10), child: savedLoginRow);

    // Text to inform user how to switch between sign in and registration pages
    Text switchPage = const Text("Swipe to Registration >>>");

    Widget appTitle = DefaultTextStyle(style: TextStyle(color: MyTheme.mainColor, fontSize: 0.1*User.screenWidthPixels, fontWeight: FontWeight.bold),
                                        child: AnimatedTextKit(animatedTexts: [WavyAnimatedText("Badger Group Up")], repeatForever: true));

    form = Column(mainAxisAlignment: MainAxisAlignment.center, children: [title, sizedEmail, sizedPassword, error ? Text(errorMessage, style: const TextStyle(color: Colors.red)) : Container(), submitPadded, forgotPassword, paddedCredentials, switchPage]);

    if (widget.animatedBackground) {
      return WillPopScope(onWillPop: () async => false, child: MaterialApp(debugShowCheckedModeBanner: false,
          home: Scaffold(resizeToAvoidBottomInset: false,
              body: AnimatedBackground(behaviour: RandomParticleBehaviour(options: const ParticleOptions(particleCount: 50, spawnMinRadius: 5, spawnMaxRadius: 13, spawnMinSpeed: 100, spawnMaxSpeed: 200, minOpacity: 0.3, maxOpacity: 0.6, image: Image(image: AssetImage("assets/bucky.png")))), vsync: this,
                  child: Stack(children:
                  [Center(child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [SizedBox(height: 0.1*User.screenHeightPixels), appTitle])), Center(child: form)]
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