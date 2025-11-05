import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UserStorageService {
  static const String _userKey = 'current_user_data';

  Future<Map<String, dynamic>?> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson != null) {
        return Map<String, dynamic>.from(json.decode(userJson));
      }
      return null;
    } catch (e) {
      print('Error loading user data: $e');
      return null;
    }
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = json.encode(userData);
      await prefs.setString(_userKey, userJson);
    } catch (e) {
      print('Error saving user data: $e');
      rethrow;
    }
  }

  Future<void> deleteUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    } catch (e) {
      print('Error deleting user data: $e');
      rethrow;
    }
  }
}