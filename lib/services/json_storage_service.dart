import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement_model.dart';

class JsonStorageService {
  static const String _achievementsKey = 'achievements_data';

  Future<List<Achievement>> loadAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final achievementsJson = prefs.getString(_achievementsKey);
      
      if (achievementsJson != null) {
        final List<dynamic> achievementsList = json.decode(achievementsJson);
        return achievementsList.map((json) => Achievement.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error loading achievements: $e');
      return [];
    }
  }

  Future<void> saveAchievements(List<Achievement> achievements) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final achievementsJson = json.encode(achievements.map((a) => a.toJson()).toList());
      await prefs.setString(_achievementsKey, achievementsJson);
    } catch (e) {
      print('Error saving achievements: $e');
      rethrow;
    }
  }

  Future<void> clearAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_achievementsKey);
    } catch (e) {
      print('Error clearing achievements: $e');
      rethrow;
    }
  }
}