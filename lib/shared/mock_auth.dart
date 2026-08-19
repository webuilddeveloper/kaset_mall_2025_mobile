import 'package:kasetmall/shared/mock_store.dart';

class MockAuth {
  static Future<bool> isLoggedIn() async {
    return MockStore.isLoggedIn();
  }

  static Future<String> displayName() async {
    return MockStore.displayName();
  }
}
