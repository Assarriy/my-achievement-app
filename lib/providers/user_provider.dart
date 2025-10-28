import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../services/user_storage_service.dart';
import '../services/image_service.dart';

class UserProvider with ChangeNotifier {
  final UserStorageService _storageService = UserStorageService();
  final ImageService _imageService = ImageService();
  final Uuid _uuid = Uuid();

  User? _currentUser;

  User? get currentUser => _currentUser;

  UserProvider() {
    loadUser();
  }

  // Load user data from storage
  Future<void> loadUser() async {
    try {
      final userData = await _storageService.loadUserData();
      if (userData != null) {
        _currentUser = User.fromJson(userData);
      } else {
        // Create default user if none exists
        _currentUser = User(
          id: _uuid.v4(),
          name: 'Nama Pengguna',
          email: 'email@example.com',
        );
        await _saveUser();
      }
      notifyListeners();
    } catch (e) {
      print('Error loading user: $e');
      // Create default user on error
      _currentUser = User(
        id: _uuid.v4(),
        name: 'Nama Pengguna',
        email: 'email@example.com',
      );
    }
  }

  // Update user profile
  Future<void> updateUser({
    required String name,
    required String email,
    bool? emailNotifications,
    bool? pushNotifications,
    File? newAvatarFile,
  }) async {
    if (_currentUser == null) return;

    try {
      String? avatarPath = _currentUser!.avatarPath;

      // Handle avatar update
      if (newAvatarFile != null) {
        // Delete old avatar if exists
        if (_currentUser!.avatarPath != null) {
          await _imageService.deleteImage(_currentUser!.avatarPath!);
        }
        // Save new avatar
        avatarPath = await _imageService.saveImagePermanently(
          newAvatarFile,
          _currentUser!.id,
        );
      }

      // Update user data
      _currentUser = _currentUser!.copyWith(
        name: name,
        email: email,
        avatarPath: avatarPath,
        emailNotifications: emailNotifications,
        pushNotifications: pushNotifications,
      );

      await _saveUser();
      notifyListeners();
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  // Save user data to storage
  Future<void> _saveUser() async {
    if (_currentUser != null) {
      await _storageService.saveUserData(_currentUser!.toJson());
    }
  }

  // Delete user avatar
  Future<void> deleteAvatar() async {
    if (_currentUser?.avatarPath != null) {
      await _imageService.deleteImage(_currentUser!.avatarPath!);
      _currentUser = _currentUser!.copyWith(avatarPath: null);
      await _saveUser();
      notifyListeners();
    }
  }
}
