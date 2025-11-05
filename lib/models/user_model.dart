class User {
  final String id;
  final String name;
  final String email;
  final String? avatarPath; // Bisa berupa file path, data URL, atau assets path
  final bool? emailNotifications;
  final bool? pushNotifications;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarPath,
    this.emailNotifications,
    this.pushNotifications,
  });

  // Konversi dari Map ke object User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarPath: json['avatarPath'] as String?,
      emailNotifications: json['emailNotifications'] as bool?,
      pushNotifications: json['pushNotifications'] as bool?,
    );
  }

  // Konversi dari object User ke Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarPath': avatarPath,
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
    };
  }

  // Copy with method untuk update
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarPath,
    bool? emailNotifications,
    bool? pushNotifications,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarPath: avatarPath ?? this.avatarPath,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
    );
  }
}