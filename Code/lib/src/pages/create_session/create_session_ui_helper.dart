// ignore_for_file: invalid_use_of_protected_member

part of 'package:badger_group_up/src/pages/create_session/create_session_page.dart';

extension CreateSessionSection on CreateSessionState {
  void onSelectLocation(int index) {
    form.location = Location.locations[index];
    loadScheduleInNewLocation(form);
    setState(() {});
  }

  void onSelectActivity(int index) {
    form.activity = Activity.activities[index];
    setState(() {});
  }

  void onSelectSkillLevel(int index) {
    form.skillLevel = SkillLevel.values[index];
    setState(() {});
  }

  void onSubmitTime() {
    String? valid = validateTimeRange(form.getBegin(), form.getEnd());
    if (valid != null) {
      DialogFactory.showToast(context, valid);
    }else{
      form.setEpoch();
    }
    setState(() {});
    Navigator.of(context).pop();
  }

  void onSelectBeginTime() {
    var widget = TimePickerFactory.buildTimePicker(form.getBegin(), (time) {
      form.setBegin(time);
    });
    if(!MyTheme.isTesting()){
      DialogFactory.popUpActionContent(
          context, "Choose time", widget, onSubmitTime, "Select");
    }
  }

  void onSelectEndTime() {
    var widget = TimePickerFactory.buildTimePicker(form.getEnd(), (time) {
      form.setEnd(time);
    });

    if(!MyTheme.isTesting()){
      DialogFactory.popUpActionContent(
          context, "Choose End time", widget, onSubmitTime, "Select");
    }
  }

  void onCheckUrgent(bool newValue) {
    setState(() {
      isUrgent = !isUrgent;
    });
  }


  Widget buildBody() {
    List<DropdownMenuItem<int>> skillDropdown = [];
    for (int i = 0; i < SkillLevel.values.length; i++) {
      var item = DropdownMenuItem<int>(
        value: (i),
        child: Text(SkillLevel.values[i].getName()),
      );
      skillDropdown.add(item);
    }

    var locationDropdown = DropDownFactory.buildDropdown(
        Location.locations, onSelectLocation,
        defaultIndex: Location.locations.indexOf(form.location));
    var nameActivityInput = DropDownFactory.buildDropdown(
        Activity.activities, onSelectActivity,
        defaultIndex: Activity.activities.indexOf(form.activity));

    ///TIME SELECTORS
    var beginTimeSelector = ButtonFactory.buildButtonConditional(
        MyTheme.printTimeShort(form.getBegin()), !isUrgent, onSelectBeginTime);
    var endTimeSelector = ButtonFactory.buildButtonStyle(
        MyTheme.printTimeShort(form.getEnd()), onSelectEndTime,
                                ElevatedButton.styleFrom(primary: MyTheme.mainColor,
                                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal)));

    var urgencyCheckbox =
        CheckboxFactory.buildCheckBox(isUrgent, onCheckUrgent);

    var desiredPeopleInput = TextFieldFactory.buildNumericField(
        controllers[iCreateSession.desiredPeople], "");
    var skillLevelDropdown = DropDownFactory.buildDropdownEnum(
        SkillLevel.values, onSelectSkillLevel, skillDropdown,
        defaultIndex: form.skillLevel.index);
    var descriptionInputField = TextFieldFactory.buildTextField(
        controllers[iCreateSession.description], 'Any other comments or notes',
        lines: 5);

    var cancelButton = ButtonFactory.buildButtonStyle("Cancel", () {
      RouteGenerator.pop(context);
    }, ElevatedButton.styleFrom(primary: MyTheme.mainColor));

    var submitButton =
        ButtonFactory.buildButtonConditional("Submit", canMakeMoreSession, () {
      onPressSubmitSession();
    });

    var beginTimeSelectorHeader = GridFactory.buildEvenRow([
      const Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            'Start Time',
            style: TextStyle(fontSize: 14),
          )),
      const Text(''),
      const Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            'End time',
            style: TextStyle(fontSize: 14),
          )),
    ]);
    var timeSelectorBlock = GridFactory.buildEvenRow(
        [beginTimeSelector, const Center(child: Text("~")), endTimeSelector]);
    var timeCannotSelectBlock = Container(
        color: MyTheme.subColor,
        child: const Center(child: Text("This location is full")));

    var urgentBox = Row(
      children: [const Text("Right now?"), urgencyCheckbox],
    );

    var peopleBlock = GridFactory.buildEvenRow(
        [const Text("Max people?"), desiredPeopleInput]);

    var buttonBlock = GridFactory.buildRow(
      {
        Container(): 1,
        cancelButton: 3,
        Container(): 1,
        submitButton: 5,
        Container(): 1,
      },
      mainAxis: MainAxisAlignment.start,
      crossAxis: CrossAxisAlignment.start,
    );

    var col = Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        locationDropdown,
        nameActivityInput,
        urgentBox,
        beginTimeSelectorHeader,
        (canMakeMoreSession) ? timeSelectorBlock : timeCannotSelectBlock,
        peopleBlock,
        skillLevelDropdown,
        descriptionInputField,
        buttonBlock,
      ],
    );
    var mainBody = SizedBox(
      height: User.screenHeightPixels * 0.9,
      width: User.screenWidthPixels,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: col,
      ),
    );

    var scroll = ListView(
//      padding: EdgeInsets.all(80),
        shrinkWrap: false,
        children: <Widget>[
          mainBody,
          //  SizedBox(height: User.screenHeightPixels, width: User.screenWidthPixels,),
        ]);

    return scroll;
  }


}
