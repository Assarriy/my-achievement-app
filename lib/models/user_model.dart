class User {
  final String id;
  final String name;
  final String email;
  final String? avatarPath;
  final bool emailNotifications;
  final bool pushNotifications;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarPath,
    this.emailNotifications = true,
    this.pushNotifications = false,
  });

  // Convert to Map for JSON storage
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

  // Create from Map (for loading from JSON)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatarPath: json['avatarPath'],
      emailNotifications: json['emailNotifications'] ?? true,
      pushNotifications: json['pushNotifications'] ?? false,
    );
  }

  // Copy with method for updates
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
