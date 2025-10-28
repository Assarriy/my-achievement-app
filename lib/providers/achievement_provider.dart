import 'dart:io';
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

  AchievementProvider() {
    // Muat data saat aplikasi pertama kali dibuka
    loadAchievements();
  }

  // Muat data dari file JSON
  Future<void> loadAchievements() async {
    _achievements = await _storageService.loadAchievements();
    sortAchievements(_sortType); // Langsung urutkan
  }

  // Tambah data baru
  Future<void> addAchievement({
    required String title,
    required DateTime date,
    required String category,
    required String description,
    File? tempImage, // File sementara dari image_picker
  }) async {
    String? permanentImagePath;
    final String newId = _uuid.v4(); // Buat ID unik

    // 1. Jika ada gambar, simpan dulu
    if (tempImage != null) {
      permanentImagePath = await _imageService.saveImagePermanently(
        tempImage,
        newId,
      );
    }

    // 2. Buat object baru
    final newAchievement = Achievement(
      id: newId,
      title: title,
      date: date,
      category: category,
      description: description,
      imagePath: permanentImagePath,
    );

    // 3. Tambahkan ke list & simpan ke JSON
    _achievements.add(newAchievement);
    await _saveAndNotify();
  }

  // Hapus data
  Future<void> deleteAchievement(String id) async {
    final achievementToRemove = _achievements.firstWhere((ach) => ach.id == id);

    // 1. Hapus gambar (jika ada)
    if (achievementToRemove.imagePath != null) {
      await _imageService.deleteImage(achievementToRemove.imagePath!);
    }

    // 2. Hapus data dari list
    _achievements.removeWhere((ach) => ach.id == id);
    await _saveAndNotify();
  }

  // Logika pengurutan
  void sortAchievements(SortType newSortType) {
    _sortType = newSortType;
    if (_sortType == SortType.byDate) {
      _achievements.sort((a, b) => b.date.compareTo(a.date)); // Terbaru dulu
    } else {
      _achievements.sort((a, b) => a.category.compareTo(b.category));
    }
    notifyListeners();
  }

  // Helper internal untuk menyimpan ke file dan memberi tahu UI
  Future<void> _saveAndNotify() async {
    await _storageService.saveAchievements(_achievements);
    sortAchievements(_sortType); // Selalu urutkan ulang setelah ada perubahan
  }

  Achievement _findAchievementById(String id) {
    return _achievements.firstWhere((ach) => ach.id == id);
  }

  // Fungsi UPDATE
  Future<void> updateAchievement({
    required String id,
    required String title,
    required DateTime date,
    required String category,
    required String description,
    File? newImageFile, // File gambar baru, bisa null
  }) async {
    try {
      final achIndex = _achievements.indexWhere((ach) => ach.id == id);
      if (achIndex == -1) {
        // Data tidak ditemukan, mungkin sudah terhapus
        return;
      }

      final oldAchievement = _achievements[achIndex];
      String? permanentImagePath = oldAchievement.imagePath; // Pakai path lama

      // Logika update gambar
      if (newImageFile != null) {
        // 1. Jika ada gambar lama, hapus dulu
        if (oldAchievement.imagePath != null) {
          await _imageService.deleteImage(oldAchievement.imagePath!);
        }
        // 2. Simpan gambar baru
        permanentImagePath = await _imageService.saveImagePermanently(
          newImageFile,
          id,
        );
      }

      // Buat object achievement yang sudah di-update
      final updatedAchievement = Achievement(
        id: id, // ID harus tetap sama
        title: title,
        date: date,
        category: category,
        description: description,
        imagePath: permanentImagePath, // Path gambar (baru atau lama)
      );

      // Ganti item lama di list dengan item baru
      _achievements[achIndex] = updatedAchievement;

      // Simpan ke file JSON dan update UI
      await _saveAndNotify();
    } catch (e) {
      print("Error updating achievement: $e");
      rethrow; // Lemparkan error agar bisa ditangkap di UI
    }
  }

  // ... (Anda bisa tambahkan fungsi updateAchievement di sini) ...
}
