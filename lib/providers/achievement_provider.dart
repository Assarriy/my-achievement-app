import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/achievement_model.dart';
import '../services/json_storage_service.dart';
import '../services/image_service.dart';

enum SortType { byDate, byCategory }

class AchievementProvider with ChangeNotifier {
  final JsonStorageService _storageService = JsonStorageService();
  final ImageService _imageService = ImageService();
  final Uuid _uuid = Uuid();

  List<Achievement> _achievements = [];
  SortType _sortType = SortType.byDate;

  List<Achievement> get achievements => _achievements;
  SortType get sortType => _sortType;

  // Get favorite achievements count
  int get favoriteCount {
    return _achievements.where((achievement) => achievement.isFavorite).length;
  }

  // Get total achievements count
  int get totalCount {
    return _achievements.length;
  }

  // Get favorite achievements
  List<Achievement> get favoriteAchievements {
    return _achievements.where((achievement) => achievement.isFavorite).toList();
  }

  AchievementProvider() {
    loadAchievements();
  }

  Future<void> loadAchievements() async {
    _achievements = await _storageService.loadAchievements();
    sortAchievements(_sortType);
  }

  Future<void> addAchievement({
    required String title,
    required DateTime date,
    required String category,
    required String description,
    File? tempImage,
    Uint8List? imageBytes,
  }) async {
    String? imagePath;
    final String newId = _uuid.v4();

    // Handle penyimpanan gambar berdasarkan platform
    if (kIsWeb) {
      if (imageBytes != null) {
        imagePath = await _imageService.saveImageFromBytes(
          imageBytes,
          'achievement_$newId.jpg',
        );
      }
    } else {
      if (tempImage != null) {
        imagePath = await _imageService.saveImagePermanently(
          tempImage,
          newId,
        );
      }
    }

    final newAchievement = Achievement(
      id: newId,
      title: title,
      date: date,
      category: category,
      description: description,
      imagePath: imagePath,
      isFavorite: false, // Default false untuk achievement baru
    );

    _achievements.add(newAchievement);
    await _saveAndNotify();
  }

  // Toggle favorite status
  Future<void> toggleFavorite(String id) async {
    try {
      final index = _achievements.indexWhere((achievement) => achievement.id == id);
      if (index != -1) {
        final updatedAchievement = _achievements[index].copyWith(
          isFavorite: !_achievements[index].isFavorite,
        );
        _achievements[index] = updatedAchievement;
        await _saveAndNotify();
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      throw Exception('Could not toggle favorite');
    }
  }

  Future<void> deleteAchievement(String id) async {
    final achievementToRemove = _achievements.firstWhere((ach) => ach.id == id);

    if (achievementToRemove.imagePath != null && 
        !achievementToRemove.imagePath!.startsWith('assets/')) {
      await _imageService.deleteImage(achievementToRemove.imagePath!);
    }

    _achievements.removeWhere((ach) => ach.id == id);
    await _saveAndNotify();
  }

  Future<void> updateAchievement({
    required String id,
    required String title,
    required DateTime date,
    required String category,
    required String description,
    File? newImageFile,
    Uint8List? newImageBytes,
  }) async {
    try {
      final achIndex = _achievements.indexWhere((ach) => ach.id == id);
      if (achIndex == -1) return;

      final oldAchievement = _achievements[achIndex];
      String? imagePath = oldAchievement.imagePath;

      if (newImageFile != null || newImageBytes != null) {
        if (oldAchievement.imagePath != null && 
            !oldAchievement.imagePath!.startsWith('assets/')) {
          await _imageService.deleteImage(oldAchievement.imagePath!);
        }
        
        if (kIsWeb && newImageBytes != null) {
          imagePath = await _imageService.saveImageFromBytes(
            newImageBytes,
            'achievement_$id.jpg',
          );
        } else if (!kIsWeb && newImageFile != null) {
          imagePath = await _imageService.saveImagePermanently(
            newImageFile,
            id,
          );
        }
      }

      // Pertahankan status favorite yang sudah ada
      final updatedAchievement = Achievement(
        id: id,
        title: title,
        date: date,
        category: category,
        description: description,
        imagePath: imagePath,
        isFavorite: oldAchievement.isFavorite, // Pertahankan status favorite
      );

      _achievements[achIndex] = updatedAchievement;
      await _saveAndNotify();
    } catch (e) {
      print("Error updating achievement: $e");
      rethrow;
    }
  }

  void sortAchievements(SortType newSortType) {
    _sortType = newSortType;
    if (_sortType == SortType.byDate) {
      _achievements.sort((a, b) => b.date.compareTo(a.date));
    } else {
      _achievements.sort((a, b) => a.category.compareTo(b.category));
    }
    notifyListeners();
  }

  Future<void> _saveAndNotify() async {
    await _storageService.saveAchievements(_achievements);
    sortAchievements(_sortType);
    notifyListeners();
  }

  Achievement? getAchievementById(String id) {
    try {
      return _achievements.firstWhere((ach) => ach.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Achievement> getAchievementsByCategory(String category) {
    return _achievements.where((ach) => ach.category == category).toList();
  }

  List<String> getCategories() {
    final categories = _achievements.map((ach) => ach.category).toSet().toList();
    categories.sort();
    return categories;
  }

  int getAchievementsCount() {
    return _achievements.length;
  }

  int getAchievementsCountByCategory(String category) {
    return _achievements.where((ach) => ach.category == category).length;
  }

  List<Achievement> getRecentAchievements({int count = 5}) {
    final sorted = List<Achievement>.from(_achievements);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(count).toList();
  }

  bool achievementExists(String id) {
    return _achievements.any((ach) => ach.id == id);
  }

  // Clear all achievements (for testing/reset)
  Future<void> clearAllAchievements() async {
    for (final achievement in _achievements) {
      if (achievement.imagePath != null && 
          !achievement.imagePath!.startsWith('assets/')) {
        await _imageService.deleteImage(achievement.imagePath!);
      }
    }
    _achievements.clear();
    await _saveAndNotify();
  }
}