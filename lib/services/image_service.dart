import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageService {
  final ImagePicker _picker = ImagePicker();

  // Default avatar path untuk assets
  static const String defaultAvatarPath = 'assets/images/avatars/default_avatar.jpeg';
  static const String defaultAchievementImage = 'assets/images/achievements/default_achievement.png';

  // 1. Ambil gambar dari galeri/kamera
  Future<Uint8List?> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        return bytes;
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  // 2. Simpan gambar ke local storage (untuk mobile) atau sebagai base64 (untuk web)
  Future<String?> saveImage(Uint8List imageBytes, String fileName) async {
    try {
      if (kIsWeb) {
        // Untuk web, simpan sebagai base64 string
        final base64String = base64.encode(imageBytes);
        return 'data:image/jpeg;base64,$base64String';
      } else {
        // Untuk mobile/desktop, simpan ke local storage
        final directory = await getApplicationDocumentsDirectory();
        final String fileExtension = '.jpg';
        final String newPath = path.join(directory.path, fileName + fileExtension);
        final File file = File(newPath);
        await file.writeAsBytes(imageBytes);
        return newPath;
      }
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }

  // 3. Simpan gambar dari bytes (khusus web)
  Future<String?> saveImageFromBytes(Uint8List bytes, String fileName) async {
    try {
      if (kIsWeb) {
        final base64String = base64.encode(bytes);
        return 'data:image/jpeg;base64,$base64String';
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final String newPath = path.join(directory.path, fileName);
        final File file = File(newPath);
        await file.writeAsBytes(bytes);
        return newPath;
      }
    } catch (e) {
      print('Error saving image from bytes: $e');
      return null;
    }
  }

  // 4. Simpan gambar permanen (untuk mobile/desktop)
  Future<String?> saveImagePermanently(File tempImage, String itemId) async {
    try {
      if (kIsWeb) {
        // Untuk web, convert file ke bytes lalu simpan sebagai base64
        final bytes = await tempImage.readAsBytes();
        final base64String = base64.encode(bytes);
        return 'data:image/jpeg;base64,$base64String';
      } else {
        // Untuk mobile/desktop
        final directory = await getApplicationDocumentsDirectory();
        final String fileExtension = path.extension(tempImage.path);
        final String newPath = path.join(directory.path, 'item_$itemId$fileExtension');
        final File newImage = await tempImage.copy(newPath);
        return newImage.path;
      }
    } catch (e) {
      print('Error saving image permanently: $e');
      return null;
    }
  }

  // 5. Hapus gambar
  Future<void> deleteImage(String imagePath) async {
    if (kIsWeb) {
      // Untuk web, gambar disimpan sebagai base64 di storage, tidak perlu hapus file
      return;
    } else {
      try {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print("Error deleting image: $e");
      }
    }
  }

  // 6. Load image sebagai bytes
  Future<Uint8List?> loadImageBytes(String imagePath) async {
    try {
      if (kIsWeb) {
        if (imagePath.startsWith('data:image')) {
          final base64String = imagePath.replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '');
          return base64.decode(base64String);
        }
        return null;
      } else {
        final file = File(imagePath);
        if (await file.exists()) {
          return await file.readAsBytes();
        }
        return null;
      }
    } catch (e) {
      print('Error loading image bytes: $e');
      return null;
    }
  }

  // 7. Method untuk mendapatkan path avatar default
  static String getDefaultAvatar() {
    return defaultAvatarPath;
  }

  // 8. Method untuk mendapatkan path achievement default
  static String getDefaultAchievementImage() {
    return defaultAchievementImage;
  }

  // 9. Check jika path adalah data URL
  bool isDataUrl(String path) {
    return kIsWeb && path.startsWith('data:image');
  }
}