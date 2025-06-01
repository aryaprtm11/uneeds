import 'package:shared_preferences/shared_preferences.dart';

class ProfilePreferences {
  static const _keyName = 'name';
  static const _keyUsername = 'username';
  static const _keyEmail = 'email';
  static const _keyPhone = 'phone';
  static const _keyProfileImage = 'profile_image';
  static const _keyBio = 'bio';
  static const _keyUniversity = 'university';
  static const _keyMajor = 'major';
  static const _keySemester = 'semester';
  static const _keyLocation = 'location';
  static const _keyGender = 'gender';
  static const _keyBirthDate = 'birth_date';

  static Future<void> saveProfile({
    required String name,
    required String username,
    required String email,
    required String phone,
    String? bio,
    String? university,
    String? major,
    String? semester,
    String? location,
    String? gender,
    String? birthDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPhone, phone);
    
    // Save optional fields
    if (bio != null) await prefs.setString(_keyBio, bio);
    if (university != null) await prefs.setString(_keyUniversity, university);
    if (major != null) await prefs.setString(_keyMajor, major);
    if (semester != null) await prefs.setString(_keySemester, semester);
    if (location != null) await prefs.setString(_keyLocation, location);
    if (gender != null) await prefs.setString(_keyGender, gender);
    if (birthDate != null) await prefs.setString(_keyBirthDate, birthDate);
  }

  static Future<Map<String, String?>> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_keyName) ?? '',
      'username': prefs.getString(_keyUsername) ?? '',
      'email': prefs.getString(_keyEmail) ?? '',
      'phone': prefs.getString(_keyPhone) ?? '',
      'bio': prefs.getString(_keyBio),
      'university': prefs.getString(_keyUniversity),
      'major': prefs.getString(_keyMajor),
      'semester': prefs.getString(_keySemester),
      'location': prefs.getString(_keyLocation),
      'gender': prefs.getString(_keyGender),
      'birth_date': prefs.getString(_keyBirthDate),
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

  static Future<void> removeProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyProfileImage);
  }

  static Future<void> clearAllProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyName);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyPhone);
    await prefs.remove(_keyBio);
    await prefs.remove(_keyUniversity);
    await prefs.remove(_keyMajor);
    await prefs.remove(_keySemester);
    await prefs.remove(_keyLocation);
    await prefs.remove(_keyGender);
    await prefs.remove(_keyBirthDate);
    await prefs.remove(_keyProfileImage);
  }
}
