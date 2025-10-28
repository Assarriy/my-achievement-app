import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:html' as html;
import '../models/achievement_model.dart';

class JsonStorageService {
  static const _fileName = 'achievements.json';

  // Helper untuk mendapatkan path direktori dokumen aplikasi (hanya untuk mobile/desktop)
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Helper untuk mendapatkan file JSON (hanya untuk mobile/desktop)
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  // FUNGSI MEMBACA DATA
  Future<List<Achievement>> loadAchievements() async {
    try {
      if (kIsWeb) {
        // Untuk web, gunakan localStorage
        final contents = html.window.localStorage[_fileName];
        if (contents == null || contents.isEmpty) {
          return [];
        }
        final List<dynamic> jsonList = jsonDecode(contents) as List<dynamic>;
        return jsonList
            .map((json) => Achievement.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        // Untuk mobile/desktop, gunakan file system
        final file = await _localFile;
        if (!await file.exists()) {
          return [];
        }
        final contents = await file.readAsString();
        if (contents.isEmpty) {
          return [];
        }
        final List<dynamic> jsonList = jsonDecode(contents) as List<dynamic>;
        return jsonList
            .map((json) => Achievement.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print("Error loading achievements: $e");
      return [];
    }
  }

  // FUNGSI MENYIMPAN DATA (Menimpa seluruh file)
  Future<void> saveAchievements(List<Achievement> achievements) async {
    try {
      final List<Map<String, dynamic>> jsonList =
          achievements.map((ach) => ach.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      if (kIsWeb) {
        // Untuk web, simpan ke localStorage
        html.window.localStorage[_fileName] = jsonString;
      } else {
        // Untuk mobile/desktop, simpan ke file
        final file = await _localFile;
        await file.writeAsString(jsonString);
      }
    } catch (e) {
      print("Error saving achievements: $e");
    }
  }
}
