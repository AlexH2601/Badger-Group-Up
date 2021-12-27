import 'package:badger_group_up/auth.config.dart';
import 'package:email_auth/email_auth.dart';

class EmailAuthentication {
  late EmailAuth emailAuthSession;

  EmailAuthentication.empty();

  EmailAuthentication(String name) {
    emailAuthSession = EmailAuth(sessionName: name);
  }

  Future<bool> sendAuthEmail(String email) async {
    await emailAuthSession.config(remoteServerConfiguration);
    return await emailAuthSession.sendOtp(recipientMail: email, otpLength: 5);
  }

  bool validateOTP(String email, String userInput) {
    return emailAuthSession.validateOtp(recipientMail: email, userOtp: userInput);
  }
}