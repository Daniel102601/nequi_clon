import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _key = "is_logged_in";

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (email == "admin@test.com" && password == "123456") {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, true);
      return true;
    }

    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}