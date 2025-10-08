import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

Future<UserCredential?> signInWithFacebook() async {
  // Trigger the sign-in flow
  final LoginResult loginResult = await FacebookAuth.instance.login();

  // Create a credential from the access token
  if (loginResult.status == LoginStatus.success) {
    final AccessToken? accessToken = loginResult.accessToken;
    final OAuthCredential credential =
        FacebookAuthProvider.credential(accessToken!.token!);
    try {
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      // manage Firebase authentication exceptions
      // ignore: avoid_print
      print('----- manage Firebase authentication exceptions ----- $e');
      return null;
    } catch (e) {
      // manage other exceptions
      // ignore: avoid_print
      print('----- manage other exceptions ----- $e');
      return null;
    }
  } else {
    // login was not successful, for example user cancelled the process
    // ignore: avoid_print
    print(
        '----- login was not successful, for example user cancelled the process -----');
    return null;
  }
}

Future<String?> getAccessTokenF() async {
  final LoginResult loginResult = await FacebookAuth.instance.login();
  final accessToken = loginResult.accessToken;
  return accessToken?.token;
}

extension on AccessToken {
  String? get token => null;
}

void logoutFacebook() async {
  await FacebookAuth.instance.logOut();
}
