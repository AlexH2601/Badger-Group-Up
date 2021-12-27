import 'package:badger_group_up/src/system/group_manager/group_manager.dart';
import 'package:badger_group_up/src/system/route_generator.dart';
import 'package:badger_group_up/src/system/session_manager/activity.dart';
import 'package:badger_group_up/src/system/session_manager/session_entry.dart';
import 'package:badger_group_up/src/system/user.dart';
import 'package:badger_group_up/src/widgets/button_factory.dart';
import 'package:badger_group_up/src/widgets/checkbox_factory.dart';
import 'package:badger_group_up/src/widgets/dialog_factory.dart';
import 'package:badger_group_up/src/widgets/dropdown_factory.dart';
import 'package:badger_group_up/src/system/session_manager/location.dart';
import 'package:badger_group_up/src/system/session_manager/session_manager.dart';
import 'package:badger_group_up/src/system/shared_values.dart';
import 'package:badger_group_up/src/widgets/grid_factory.dart';
import 'package:badger_group_up/src/widgets/textfield_factory.dart';
import 'package:badger_group_up/src/widgets/time_picker_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math';

part 'package:badger_group_up/src/pages/create_session/create_session_ui_helper.dart';

enum iCreateSession { activityName, desiredPeople, description }

class CreateSession extends StatefulWidget {
  const CreateSession({Key? key}) : super(key: key);

  @override
  CreateSessionState createState() => CreateSessionState();
}

class CreateSessionState extends State<CreateSession> {
  SessionEntry form = SessionEntry();
  bool canMakeMoreSession = true;

  bool isSubmitting = false; //Database semaphore
  bool isUrgent = false;
  final Map<iCreateSession, TextEditingController> controllers = {
    iCreateSession.activityName: TextEditingController(),
    iCreateSession.desiredPeople: TextEditingController(),
    iCreateSession.description: TextEditingController(),
  };

  void loadInitialStatus() {
    form.desiredPeople = 5;
    form.activity = Activity.activities[0];
    form.location = Location.locations[0];
    form.hostEmail=User.userEmail;
    loadScheduleInNewLocation(form);
    controllers[iCreateSession.activityName]!.text = form.activity;
    controllers[iCreateSession.desiredPeople]!.text =
        form.desiredPeople.toString();
    isSubmitting = false;
  }

  bool loadScheduleInNewLocation(SessionEntry entry) {
    canMakeMoreSession = SessionManager.instance.setEarliestCompatibleSchedule(
        form, DateTime.now(), const Duration(minutes: 15));
    return canMakeMoreSession;
  }

  void fillForms() {
    form.generateID();
    form.status = SessionStatus.Open;
    form.hostEmail = User.userEmail;
    //Activity is filled from dropdown
    //Location is filled from dropdown
    form.description = controllers[iCreateSession.description]!.text;
    //Time filled by time picker
    form.desiredPeople = max(
        int.parse(controllers[iCreateSession.desiredPeople]!.text),
        1); //Min 1 person requied
    form.status = SessionStatus.Open;
    //Time SkillLevel by time picker
  }

  String? validateTimeRange(DateTime begin, DateTime end) {
    if (end.isBefore(begin)) {
      return "Invalid time span \n Session ends before starts";
    }
    if (end.isBefore(DateTime.now())) {
      return "Invalid time span \n This session already finished";
    }
    if (end.difference(begin).inMinutes < 1) {
      return "Invalid time span \n [Start time equals end time]";
    }
    return null;
  }

  String? doValidationCheck(SessionEntry entry) {
    if (SessionManager.instance.hasSession(entry.id)) return "Invalid ID";
    if (entry.status != SessionStatus.Open) return "Invalid Status";
    if (entry.hostEmail != User.userEmail) return "Invalid host mail";
    if (Location.getLocationByID(entry.location.id) == null) {
      return "Invalid Location";
    }
    if (entry.description.length >= 500) {
      entry.description = form.description.substring(0, 500);
    }
    if (entry.desiredPeople < 1) return "Too small people";
    debugPrint(entry.getBegin().toString() + " ~ " + entry.getEnd().toString());
    String? timeValid = validateTimeRange(entry.getBegin(), entry.getEnd());
    if (timeValid != null) return timeValid;
    if (!canMakeMoreSession) return "Location is full today";
    if (SessionManager.instance.isScheduleCompatible(entry) != null) {
      return "This places or time is already booked \n"+
    "By "+entry.toString();
    }
    return null;
  }

  void onPressSubmitSession() async {
    if (isSubmitting) return;
    isSubmitting = true;
    try {
      bool success = await SessionManager.instance.loadSessions();
      if (!success) {
        throw Exception("Failed Communication");
      }

      //Check validity
      fillForms();
      String? checkResult = doValidationCheck(form);
      if (checkResult != null) {
        throw Exception(checkResult);
      }
      //Push data
      success = await SessionManager.instance.createSession(form);
      if (!success) {
        throw Exception("Failed Communication");
      }
      success = await GroupManager.joinGroup(form.id);
      isSubmitting = false;
      if (!success) {
        throw Exception("Failed Join");
      }
      DialogFactory.showToast(context, "You have created a session!");
      RouteGenerator.pop(context);
    } catch (exception) {
      isSubmitting = false;
      DialogFactory.showToast(
          context, "Sorry, an error has occurred.\n" + exception.toString());
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    loadInitialStatus();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
                backgroundColor: MyTheme.mainColor,
                titleSpacing: 0,
                title: Row(children: [
                  ButtonFactory.buildExitIcon(context),
                  const Text('Create a beacon')
                ])),
            body: buildBody()));
  }
}
