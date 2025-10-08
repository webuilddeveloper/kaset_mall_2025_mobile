// import 'package:flutter_login_facebook/flutter_login_facebook.dart';

// final FacebookLogin fb = FacebookLogin();

// Future<void> facebookSignIn() async {
//   final res = await fb.logIn(permissions: [
//     FacebookPermission.publicProfile,
//     FacebookPermission.email,
//   ]);

//   switch (res.status) {
//     case FacebookLoginStatus.success:
//       final accessToken = res.accessToken?.token;
//       print('Logged in! Token: $accessToken');
//       break;

//     case FacebookLoginStatus.cancel:
//       print('Login canceled by user.');
//       break;

//     case FacebookLoginStatus.error:
//       print('Login error: ${res.error}');
//       break;
//   }
// }

// Future<String?> getAccessTokenF() async {
//   final accessToken = await fb.accessToken;
//   return accessToken?.token;
// }

// Future<void> logoutFacebook() async {
//   await fb.logOut();
//   print('Logged out from Facebook');
// }
