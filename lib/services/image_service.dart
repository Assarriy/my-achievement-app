import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path; // Tambahkan 'as path'

class ImageService {
  final ImagePicker _picker = ImagePicker();

  // 1. Ambil gambar dari galeri/kamera
  Future<File?> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // 2. Simpan gambar ke direktori permanen aplikasi
  Future<String> saveImagePermanently(File tempImage, String achievementId) async {
    final directory = await getApplicationDocumentsDirectory();
    final String fileExtension = path.extension(tempImage.path);
    // Buat nama file unik, misal: 'ach_ID_12345.jpg'
    final String newPath = path.join(directory.path, 'ach_$achievementId$fileExtension');

    final File newImage = await tempImage.copy(newPath);
    return newImage.path;
  }

  // 3. Hapus gambar saat achievement dihapus
  Future<void> deleteImage(String imagePath) async {
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