import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path; // Tambahkan 'as path'

class ImageService {
  final ImagePicker _picker = ImagePicker();

  // 1. Ambil gambar dari galeri/kamera
  Future<File?> pickImage() async {
    if (kIsWeb) {
      // Untuk web, gunakan image picker web
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } else {
      // Untuk mobile/desktop
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    }
  }

  // 2. Simpan gambar ke direktori permanen aplikasi
  Future<String?> saveImagePermanently(File tempImage, String achievementId) async {
    if (kIsWeb) {
      // Untuk web, simpan sebagai base64 di localStorage atau gunakan blob
      // Namun, untuk kesederhanaan, kita bisa menyimpan path sementara atau menggunakan localStorage untuk metadata
      // Karena web tidak memiliki file system permanen seperti mobile, kita bisa return path asli atau null
      // Untuk demo, kita return path asli (akan hilang saat refresh)
      return tempImage.path;
    } else {
      // Untuk mobile/desktop
      final directory = await getApplicationDocumentsDirectory();
      final String fileExtension = path.extension(tempImage.path);
      final String newPath = path.join(directory.path, 'ach_$achievementId$fileExtension');
      final File newImage = await tempImage.copy(newPath);
      return newImage.path;
    }
  }

  // 3. Hapus gambar saat achievement dihapus
  Future<void> deleteImage(String imagePath) async {
    if (kIsWeb) {
      // Untuk web, gambar mungkin tidak permanen, jadi tidak perlu hapus
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
}
