import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Anda mungkin perlu menambahkan package 'intl'
import '../models/achievement_model.dart';
import '../screens/add_edit_screen.dart'; // Untuk navigasi edit

class AchievementListItem extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback onDismissed; // Fungsi yang dipanggil saat di-swipe

  const AchievementListItem({
    Key? key,
    required this.achievement,
    required this.onDismissed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format tanggal agar mudah dibaca
    final formattedDate = DateFormat('d MMMM yyyy').format(achievement.date);

    return Dismissible(
      key: Key(achievement.id), // Kunci unik untuk setiap item
      direction: DismissDirection.endToStart, // Geser dari kanan ke kiri
      onDismissed: (direction) {
        onDismissed(); // Panggil fungsi hapus dari provider
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        child: ListTile(
          // Menampilkan gambar jika ada, jika tidak, tampilkan ikon kategori
          leading: achievement.imagePath != null
              ? CircleAvatar(
                  backgroundImage: FileImage(File(achievement.imagePath!)),
                  radius: 25,
                )
              : CircleAvatar(
                  radius: 25,
                  child: Icon(Icons.star), // Ganti dengan ikon per kategori jika mau
                ),
          title: Text(
            achievement.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('${achievement.category} - $formattedDate'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Navigasi ke halaman Edit
            // (Anda perlu menyesuaikan AddEditScreen untuk menerima data achievement)
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => AddEditScreen(
                  // achievementToEdit: achievement, // Kirim data untuk mode edit
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}