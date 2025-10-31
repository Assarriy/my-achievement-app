import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import '../models/category_model.dart';

class CategoryStorageService {
  static const _fileName = 'categories.json'; // Nama file baru

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  // Memuat daftar kategori
  Future<List<Category>> loadCategories() async {
    try {
      final file = await _localFile;

      if (await file.exists()) {
        final contents = await file.readAsString();
        if (contents.isEmpty) return [];
        
        final List<dynamic> jsonList = jsonDecode(contents) as List<dynamic>;
        return jsonList
            .map((json) => Category.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        // Memuat dari assets jika file lokal belum ada
        final String jsonString =
            await rootBundle.loadString('assets/preload_categories.json');
        
        final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
        List<Category> categories = jsonList
            .map((json) => Category.fromJson(json as Map<String, dynamic>))
            .toList();
            
        // Simpan data preload ke file lokal
        await saveCategories(categories);
        return categories;
      }
    } catch (e) {
      print("Error loading categories: $e");
      return [];
    }
  }

  // Menyimpan daftar kategori
  Future<void> saveCategories(List<Category> categories) async {
    try {
      final file = await _localFile;
      final List<Map<String, dynamic>> jsonList =
          categories.map((cat) => cat.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await file.writeAsString(jsonString);
    } catch (e) {
      print("Error saving categories: $e");
    }
  }
}