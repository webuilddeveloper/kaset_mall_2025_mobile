import 'package:google_sign_in/google_sign_in.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId:
      '773066081983-eqsp8qc9fridlun1s4k7fdvhmjl6kpvu.apps.googleusercontent.com',
  scopes: [
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

// ฟังก์ชันล็อกอิน Google Sign-In
Future<GoogleSignInAccount?> loginGoogle() async {
  try {
    // ตรวจสอบว่ามีการล็อกอินอยู่แล้วหรือไม่
    GoogleSignInAccount? user =
        _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();

    if (user == null) {
      user = await _googleSignIn.signIn();
    }

    if (user == null) {
      print("User cancelled the login");
    } else {
      print("User signed in: ${user.email}");
    }

    return user;
  } catch (e) {
    print("Error logging in with Google: $e");
    return null;
  }
}

Future<String?> getAccessTokenG() async {
  try {
    GoogleSignInAccount? user =
        _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();

    if (user == null) {
      user = await _googleSignIn.signIn();
    }

    if (user == null) {
      print("❌ User cancelled the login");
      return null;
    }

    GoogleSignInAuthentication googleAuth = await user.authentication;

    if (googleAuth.accessToken == null) {
      print("❌ Access Token is NULL");
      return null;
    }

    print("✅ Access Token: ${googleAuth.accessToken}");
    return googleAuth.accessToken;
  } catch (e) {
    print("❌ Error getting access token: $e");
    return null;
  }
}

// ฟังก์ชัน Logout Google
Future<void> logoutGoogle() async {
  try {
    await _googleSignIn.signOut();
    print("User signed out");
  } catch (e) {
    print("Error signing out: $e");
  }
}
