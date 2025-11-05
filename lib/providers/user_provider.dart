import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../services/user_storage_service.dart';
import '../services/image_service.dart';
import 'dart:typed_data';

class UserProvider with ChangeNotifier {
  final UserStorageService _storageService = UserStorageService();
  final ImageService _imageService = ImageService();
  final Uuid _uuid = Uuid();

  User? _currentUser;

  User? get currentUser => _currentUser;

  UserProvider() {
    loadUser();
  }

  Future<void> loadUser() async {
    try {
      final userData = await _storageService.loadUserData();
      if (userData != null) {
        _currentUser = User.fromJson(userData);
      } else {
        // Create default user dengan avatar dari assets
        _currentUser = User(
          id: _uuid.v4(),
          name: 'Nama Pengguna',
          email: 'email@example.com',
          avatarPath: ImageService.defaultAvatarPath,
          emailNotifications: true,
          pushNotifications: false,
        );
        await _saveUser();
      }
      notifyListeners();
    } catch (e) {
      print('Error loading user: $e');
      _currentUser = User(
        id: _uuid.v4(),
        name: 'Nama Pengguna',
        email: 'email@example.com',
        avatarPath: ImageService.defaultAvatarPath,
        emailNotifications: true,
        pushNotifications: false,
      );
    }
  }

  Future<void> updateUser({
    required String name,
    required String email,
    bool? emailNotifications,
    bool? pushNotifications,
    Uint8List? newAvatarBytes,
  }) async {
    if (_currentUser == null) return;

    try {
      String? avatarPath = _currentUser!.avatarPath;

      // Handle avatar update
      if (newAvatarBytes != null) {
        // Delete old avatar jika bukan default avatar dari assets
        if (_currentUser!.avatarPath != null && 
            !_currentUser!.avatarPath!.startsWith('assets/')) {
          await _imageService.deleteImage(_currentUser!.avatarPath!);
        }
        
        // Save new avatar
        avatarPath = await _imageService.saveImage(
          newAvatarBytes,
          'avatar_${_currentUser!.id}',
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

  // Reset ke default avatar dari assets
  Future<void> resetToDefaultAvatar() async {
    if (_currentUser == null) return;

    try {
      // Delete old avatar jika bukan default
      if (_currentUser!.avatarPath != null && 
          !_currentUser!.avatarPath!.startsWith('assets/')) {
        await _imageService.deleteImage(_currentUser!.avatarPath!);
      }

      _currentUser = _currentUser!.copyWith(
        avatarPath: ImageService.defaultAvatarPath,
      );

      await _saveUser();
      notifyListeners();
    } catch (e) {
      print('Error resetting avatar: $e');
      rethrow;
    }
  }

  Future<void> _saveUser() async {
    if (_currentUser != null) {
      await _storageService.saveUserData(_currentUser!.toJson());
    }
  }

  Future<void> deleteAvatar() async {
    if (_currentUser?.avatarPath != null && 
        !_currentUser!.avatarPath!.startsWith('assets/')) {
      await _imageService.deleteImage(_currentUser!.avatarPath!);
      _currentUser = _currentUser!.copyWith(avatarPath: ImageService.defaultAvatarPath);
      await _saveUser();
      notifyListeners();
    }
  }

  // Update user preferences only
  Future<void> updatePreferences({
    bool? emailNotifications,
    bool? pushNotifications,
  }) async {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(
      emailNotifications: emailNotifications,
      pushNotifications: pushNotifications,
    );

    await _saveUser();
    notifyListeners();
  }
}