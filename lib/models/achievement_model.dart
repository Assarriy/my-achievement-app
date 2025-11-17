class Achievement {
  final String id;
  final String title;
  final DateTime date;
  final String category;
  final String description;
  final String? imagePath;
  final bool isFavorite; // Tambahkan properti favorite

  Achievement({
    required this.id,
    required this.title,
    required this.date,
    required this.category,
    required this.description,
    this.imagePath,
    this.isFavorite = false, // Default value false
  });

  // Konversi dari Map (hasil jsonDecode) ke object Achievement
  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      category: json['category'] as String,
      description: json['description'] as String,
      imagePath: json['imagePath'] as String?,
      isFavorite: json['isFavorite'] ?? false, // Load dari JSON
    );
  }

  // Konversi dari object Achievement ke Map (untuk jsonEncode)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'category': category,
      'description': description,
      'imagePath': imagePath,
      'isFavorite': isFavorite, // Tambahkan ke JSON
    };
  }

  // Copy with method untuk update
  Achievement copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? category,
    String? description,
    String? imagePath,
    bool? isFavorite, // Tambahkan di copyWith
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      category: category ?? this.category,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}