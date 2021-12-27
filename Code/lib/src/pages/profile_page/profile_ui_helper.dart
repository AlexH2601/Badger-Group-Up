part of 'package:badger_group_up/src/pages/profile_page/profile_page.dart';

///Progress
/// Base UI <--
/// Connect to DB
/// Implement Functions
/// Finish UI overflow
///
extension ProfileSection on ProfilePageState {
  void resetPassword() async{
    if(passwordTextControllers['newPassword']!.text.length < 3){
      DialogFactory.popUpMessage(context, 'Error', 'Please use a 3+ character password.');
    }
    else{
      Map<String, String> newValues = {
        'password': sha256.convert(utf8.encode(passwordTextControllers['newPassword']!.text)).toString(),
      };

      Map<String, String> dbValues = {
        'email': sha256.convert(utf8.encode(User.userEmail)).toString(),
      };

      bool success = await Database.instance.update('User', newValues, dbValues);

      if (success) {
        DialogFactory.popUpMessage(context, 'Password Changed', 'New Password: ' + passwordTextControllers['newPassword']!.text);
      }
      else {
        DialogFactory.popUpMessage(context, 'Error', 'Sorry, an error has occurred.');
      }
    }
  }

  resetPasswordDialog() {//build alert message before resetting password
    Widget cancelButton = TextButton(
      child:const Text('Cancel'),
      onPressed:  () {Navigator.pop(context);},
    );
    Widget continueButton = TextButton(
      child:const Text('Reset'),
      onPressed:  () {resetPassword();},
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title:const Text('Reset Password'),
      content: TextField(controller: passwordTextControllers['newPassword'],
          decoration: const InputDecoration(labelText: 'Enter New Password')),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void deleteAccountDB() async {
    Map<String, String> dbValues = {
      'email': sha256.convert(utf8.encode(User.userEmail)).toString(),
    };
    bool success = await GroupManager.removeAllfromUser(User.userEmail);
    if(success){
      success =await Database.instance.delete('User', dbValues);
    }
    if (!success) {
      // Failed response
      DialogFactory.popUpMessage(context, 'Error', 'Sorry, an error has occurred.');
    }
    else {
      User.logout();
      // Alert dialog before exit
      //await confirmDeletionDialog(context);
      DialogFactory.showToast(context, "Good Bye!");
      while(Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => Login(animatedBackground: User.animatedBackground)));
    }
  }

  deleteAccountDialog() {//build alert message before deleting account
    Widget cancelButton = TextButton(
      child:const Text('No'),
      onPressed:  () {Navigator.pop(context);},
    );
    Widget continueButton = TextButton(
      child:const Text('Yes, continue'),
      onPressed:  () {deleteAccountDB();},
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text('Do you wish to delete your account?'),
      content:const  Text('You will be automatically signed out.'),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget buildBody() {
    var emailText = Center(child: Text(User.userEmail, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)));
    var nameText = Center(child: Text(User.firstName + ' ' + User.lastName, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)));
    var resetPasswordButton = ElevatedButton(style: ButtonStyle(backgroundColor: MaterialStateProperty.all(MyTheme.mainColor)),
        onPressed: () {resetPasswordDialog();},
        child: const Text('Reset Password')
    );
    var deleteAccountButton = ElevatedButton(style: ButtonStyle(backgroundColor: MaterialStateProperty.all(MyTheme.mainColor)),
        onPressed: () {deleteAccountDialog();},
        child: const Text('Delete Account')
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        nameText,
        emailText,
        resetPasswordButton,
        deleteAccountButton
      ],
    );
  }
}
