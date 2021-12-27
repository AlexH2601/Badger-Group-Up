class User {
  static bool animatedBackground = true;
  static double screenWidthPixels = 360;
  static double screenHeightPixels = 592;

  static String userEmail = '';
  static String firstName = '';
  static String lastName = '';
  static String creationDate = '';

  static bool loadUserInfo(Map<String, String> userValues){
    if (userValues['email'] == null) return false;
    if (userValues['firstName'] == null) return false;
    if (userValues['lastName'] == null) return false;
    if (userValues['creationDate'] == null) return false;

    userEmail = userValues['email'].toString();
    firstName = userValues['firstName'].toString();
    lastName = userValues['lastName'].toString();
    creationDate = userValues['creationDate'].toString();
    return true;
  }

  static void logout() {
    userEmail = '';
    firstName = '';
    lastName = '';
    creationDate = '';
  }
}
