import 'dart:math';

class Activity {
  static Random rng = Random();

  ///Test dummy functions
  ///Activity may need to be a class. Why?
  /// If we allow free input in future development, -> list of string won't work.
  /// We may want to link like Icon to each Activity.
  ///
  /// But I made it into list of strings... why?;;;
  /// We are gonna reference activities a lot and with list searchtime is O(N)
  /// We need a Map sructure to make search O(1)
  ///
  /// But then we need to build this map in runtime by calling the function.
  /// I didn't like that dangling need of calling Activity.buildMap in some random places.... like log in page.
  /// But probbly we should go this way.. at some point..
  ///
  static List<String> activities = [
    "Tennis",
    "Basketball",
    "Volleyball",
    "Soccer",
    "Spikeball"
  ];

  ///Test dummy functions
  ///

  static String getRandom() {
    return activities[rng.nextInt(activities.length)];
  }
}
