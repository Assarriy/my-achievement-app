import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/achievement_model.dart';

class JsonStorageService {
  static const _fileName = 'achievements.json';

  // Helper untuk mendapatkan path direktori dokumen aplikasi
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Helper untuk mendapatkan file JSON
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  // FUNGSI MEMBACA DATA
  Future<List<Achievement>> loadAchievements() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return []; // Kembalikan list kosong jika file belum ada
      }

      // Baca file
      final contents = await file.readAsString();
      if (contents.isEmpty) {
        return [];
      }

      // Ubah String JSON menjadi List<dynamic> (List of Maps)
      final List<dynamic> jsonList = jsonDecode(contents) as List<dynamic>;

      // Ubah setiap Map menjadi object Achievement
      return jsonList
          .map((json) => Achievement.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error loading achievements: $e");
      return [];
    }
  }

  // FUNGSI MENYIMPAN DATA (Menimpa seluruh file)
  Future<void> saveAchievements(List<Achievement> achievements) async {
    try {
      final file = await _localFile;

      // Ubah List<Achievement> menjadi List<Map>
      final List<Map<String, dynamic>> jsonList =
          achievements.map((ach) => ach.toJson()).toList();

      // Ubah List<Map> menjadi String JSON
      final jsonString = jsonEncode(jsonList);

      // Tulis String JSON ke file
      await file.writeAsString(jsonString);
    } catch (e) {
      print("Error saving achievements: $e");
    }
  }
}