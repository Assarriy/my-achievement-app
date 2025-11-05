class Achievement {
  final String id;
  final String title;
  final DateTime date;
  final String category;
  final String description;
  final String? imagePath; // Menyimpan PATH file lokal, bukan file-nya

  Achievement({
    required this.id,
    required this.title,
    required this.date,
    required this.category,
    required this.description,
    this.imagePath,
  });

  // Konversi dari Map (hasil jsonDecode) ke object Achievement
  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String), // Simpan sbg String ISO
      category: json['category'] as String,
      description: json['description'] as String,
      imagePath: json['imagePath'] as String?,
    );
  }

  // Konversi dari object Achievement ke Map (untuk jsonEncode)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(), // Simpan sbg String, lebih aman
      'category': category,
      'description': description,
      'imagePath': imagePath,
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
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      category: category ?? this.category,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}