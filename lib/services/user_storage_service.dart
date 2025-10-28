import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:html' as html;

class UserStorageService {
  static const _userFileName = 'user.json';

  // Helper untuk mendapatkan path direktori dokumen aplikasi (hanya untuk mobile/desktop)
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Helper untuk mendapatkan file JSON user (hanya untuk mobile/desktop)
  Future<File> get _userFile async {
    final path = await _localPath;
    return File('$path/$_userFileName');
  }

  // FUNGSI MEMBACA DATA USER
  Future<Map<String, dynamic>?> loadUserData() async {
    try {
      if (kIsWeb) {
        // Untuk web, gunakan localStorage
        final contents = html.window.localStorage[_userFileName];
        if (contents == null || contents.isEmpty) {
          return null;
        }
        return jsonDecode(contents) as Map<String, dynamic>;
      } else {
        // Untuk mobile/desktop, gunakan file system
        final file = await _userFile;
        if (!await file.exists()) {
          return null;
        }
        final contents = await file.readAsString();
        if (contents.isEmpty) {
          return null;
        }
        return jsonDecode(contents) as Map<String, dynamic>;
      }
    } catch (e) {
      print("Error loading user data: $e");
      return null;
    }
  }

  // FUNGSI MENYIMPAN DATA USER
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final jsonString = jsonEncode(userData);

      if (kIsWeb) {
        // Untuk web, simpan ke localStorage
        html.window.localStorage[_userFileName] = jsonString;
      } else {
        // Untuk mobile/desktop, simpan ke file
        final file = await _userFile;
        await file.writeAsString(jsonString);
      }
    } catch (e) {
      print("Error saving user data: $e");
    }
  }
}
