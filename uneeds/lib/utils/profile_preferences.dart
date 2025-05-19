import 'package:shared_preferences/shared_preferences.dart';

class ProfilePreferences {
  static const _keyName = 'name';
  static const _keyUsername = 'username';
  static const _keyEmail = 'email';
  static const _keyPhone = 'phone';
  static const _keyProfileImage = 'profile_image';

  static Future<void> saveProfile({
    required String name,
    required String username,
    required String email,
    required String phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPhone, phone);
  }

  static Future<Map<String, String>> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_keyName) ?? '',
      'username': prefs.getString(_keyUsername) ?? '',
      'email': prefs.getString(_keyEmail) ?? '',
      'phone': prefs.getString(_keyPhone) ?? '',
    };
  }

  static Future<void> saveProfileImage(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfileImage, imagePath);
  }

  static Future<String?> getProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyProfileImage);
  }
}
