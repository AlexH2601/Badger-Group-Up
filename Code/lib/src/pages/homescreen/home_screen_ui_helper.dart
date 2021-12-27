// ignore_for_file: invalid_use_of_protected_member

part of 'package:badger_group_up/src/pages/homescreen/home_screen_page.dart';

///This file is part of HomeScreenPage
///Divided into 2,
///This only contains functions related to drawing UI
///main file contains functional methods.

extension Section on HomeScreenState {
  Widget getTimeBox(Function refresh) {
    var timeCheckbox = CheckboxFactory.buildCheckBox(
        Filter.sessionFilter.searchClosed, (value) {
      Filter.sessionFilter.searchClosed = !Filter.sessionFilter.searchClosed;
      refresh(() {});
    });
    var timeHeader = const Text("\ Show closed sessions");
    var timeRow = GridFactory.buildRow({timeCheckbox: 1, timeHeader: 5});
    return timeRow;
  }

  Widget getLocationBox(Function refresh) {
    var locationCheckbox = CheckboxFactory.buildCheckBox(
        Filter.sessionFilter.searchLocation, (value) {
      Filter.sessionFilter.searchLocation =
          !Filter.sessionFilter.searchLocation;
      refresh(() {});
    });
    var locationDropdown =
        DropDownFactory.buildDropdown(Location.locations, (int newValue) {
      Filter.sessionFilter.location = newValue;
      refresh(() {});
    }, defaultIndex: Filter.sessionFilter.location);
    var locationHeader = const Align(
        alignment: Alignment.centerLeft, child: Text("\tSelect Location ... "));

    var cont = (Filter.sessionFilter.searchLocation)
        ? locationDropdown
        : Container(color: MyTheme.disabledColor);
    var locationRow = GridFactory.buildRow({locationCheckbox: 1, cont: 5});
    var locationBox =
        GridFactory.buildColumn({locationHeader: 1, locationRow: 2});
    return locationBox;
  }

  Widget getActivityBox(Function refresh) {
    var actDropdown =
        DropDownFactory.buildDropdown(Activity.activities, (int newValue) {
      Filter.sessionFilter.activity = newValue;
      refresh(() {});
    }, defaultIndex: Filter.sessionFilter.activity);
    var actCheckbox = CheckboxFactory.buildCheckBox(
        Filter.sessionFilter.searchActivity, (value) {
      Filter.sessionFilter.searchActivity =
          !Filter.sessionFilter.searchActivity;
      refresh(() {});
    });
    var actHeader = const Align(
        alignment: Alignment.centerLeft, child: Text("\tSelect Activity ... "));
    var cont = (Filter.sessionFilter.searchActivity)
        ? actDropdown
        : Container(color: MyTheme.disabledColor);
    var actRow = GridFactory.buildRow({actCheckbox: 1, cont: 5});
    var actBox = GridFactory.buildColumn({actHeader: 1, actRow: 2});
    return actBox;
  }

  StatefulBuilder getFilterDialog() {
    return StatefulBuilder(builder: (context, setState) {
      //Time box
      var tim = getTimeBox(setState);
      var loc = getLocationBox(setState);
      var act = getActivityBox(setState);
      var col = GridFactory.buildEvenColumn([tim, loc, act]);

      var box = SizedBox(
        width: User.screenWidthPixels * 0.765,
        height: User.screenHeightPixels * 0.223,
        child: col,
      );

      var resetButton = ButtonFactory.buildButton("Reset", () {
        Filter.sessionFilter.reset();
        setState(() {});
      });

      var submitButton = ButtonFactory.buildButton("Apply", () {
        Navigator.of(context).pop();
      });

      return AlertDialog(
        content: box,
        actions: <Widget>[resetButton, submitButton],
      );
    });
  }

  void onPressFilterButton() async {
    var dialog = getFilterDialog();
    await showDialog(context: context, builder: (context) => dialog);
    setState(() {});
  }

  Widget getFilterIcon() {
    return
      isMapView ? Container() : Container(
        padding: const EdgeInsets.fromLTRB(10,0,10,10),
        child: Row(

            mainAxisAlignment: MainAxisAlignment.start, children: [
          ElevatedButton(
              onPressed: () {
                onPressFilterButton();
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(MyTheme.mainColor)),
              child: const Icon(Icons.search)),
          SizedBox(width: (1 / 25) * User.screenWidthPixels)
        ])
      );
  }

  Widget getBottom() {
    var filterIcon = getFilterIcon();
    var body = Container(
      color: MyTheme.mainColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IconButton(
              onPressed: () {
                navigateTo(RouteGenerator.sessionHistory);
              },
              color: Colors.white,
              icon: const Icon(Icons.history)),
          IconButton(
              onPressed: () {
                navigateTo(RouteGenerator.createSession);
              },
              color: Colors.white,
              icon: const Icon(Icons.add)),
          IconButton(
              onPressed: () {
                switchView();
              },
              color: Colors.white,
              icon: Icon((isMapView) ? Icons.list : Icons.map_outlined)),
        ],
      ),
    );

    var col = GridFactory.buildColumn({Container(): 7, filterIcon: 1, body: 1});
    return col;
  }
}
