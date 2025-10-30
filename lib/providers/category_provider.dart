import 'package:flutter/foundation.dart' hide Category;
import '../models/category_model.dart';
import '../services/category_storage_service.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryStorageService _storageService = CategoryStorageService();
  List<Category> _categories = [];

  List<Category> get categories => _categories;

  CategoryProvider() {
    loadCategories();
  }

  Future<void> loadCategories() async {
    _categories = await _storageService.loadCategories();
    _sortCategories();
    notifyListeners();
  }

  Future<void> addCategory(String name) async {
    // Cek agar tidak duplikat (case insensitive)
    if (_categories.any((cat) => cat.name.toLowerCase() == name.toLowerCase())) {
      // Mungkin bisa lempar error
      return;
    }
    final newCategory = Category.createNew(name);
    _categories.add(newCategory);
    await _saveAndNotify();
  }

  Future<void> updateCategory(String id, String newName) async {
    final index = _categories.indexWhere((cat) => cat.id == id);
    if (index != -1) {
      _categories[index] = Category(id: id, name: newName);
      await _saveAndNotify();
    }
  }

  Future<void> deleteCategory(String id) async {
    _categories.removeWhere((cat) => cat.id == id);
    await _saveAndNotify();
    // TODO: Anda mungkin perlu menangani apa yang terjadi
    // pada achievement yang menggunakan kategori ini
  }

  void _sortCategories() {
    _categories.sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> _saveAndNotify() async {
    _sortCategories();
    await _storageService.saveCategories(_categories);
    notifyListeners();
  }
}