import 'package:uuid/uuid.dart';

class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});

  // Factory constructor untuk membuat kategori baru dengan ID unik
  factory Category.createNew(String name) {
    return Category(id: Uuid().v4(), name: name);
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}