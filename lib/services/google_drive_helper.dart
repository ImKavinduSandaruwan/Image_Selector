import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;


class GoogleDriveHelper{
  static GoogleSignInAccount? currentUser;

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '774277295534-c3fvf282b6u1mj30kil3l9g7g423brdr.apps.googleusercontent.com',
    scopes: [
      drive.DriveApi.driveFileScope,
    ],
  );

  static Future<void> handleSignIn() async {
    try {
      final account = await _googleSignIn.signInSilently();
      if (account == null) {
        final interactiveAccount = await _googleSignIn.signIn();
        currentUser = interactiveAccount;
      } else {
        currentUser = account;
      }
    } catch (error) {
      print('Sign-in error: $error');
    }
  }
}