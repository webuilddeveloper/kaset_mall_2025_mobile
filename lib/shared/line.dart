import 'package:flutter_line_sdk/flutter_line_sdk.dart';

Future<LoginResult> loginLine() async {
  final loginOption = LoginOption(false, 'normal', requestCode: 8192);

  return await LineSDK.instance.login(
    scopes: ["profile", "openid", "email"],
    option: loginOption,
  );
}

Future<StoredAccessToken?> getAccessTokenL() async {
  return await LineSDK.instance.currentAccessToken;
  // ignore: dead_code
}

void logoutLine() {
  LineSDK.instance.logout();
}
