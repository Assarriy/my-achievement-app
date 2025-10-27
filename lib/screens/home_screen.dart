import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/achievement_provider.dart';
import '../widgets/achievement_list_item.dart';
import 'add_edit_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Tonton perubahan pada AchievementProvider
    final provider = context.watch<AchievementProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text("My Achievements"),
        actions: [
          // Tombol Sortir
          PopupMenuButton<SortType>(
            icon: Icon(Icons.sort),
            onSelected: (SortType result) {
              // Panggil fungsi sort di provider
              provider.sortAchievements(result);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortType>>[
              const PopupMenuItem<SortType>(
                value: SortType.byDate,
                child: Text('Urutkan berdasarkan Tanggal'),
              ),
              const PopupMenuItem<SortType>(
                value: SortType.byCategory,
                child: Text('Urutkan berdasarkan Kategori'),
              ),
            ],
          ),
        ],
      ),
      body: provider.achievements.isEmpty
          ? Center(child: Text("Belum ada prestasi. Ayo tambahkan!"))
          : ListView.builder(
              itemCount: provider.achievements.length,
              itemBuilder: (ctx, index) {
                final achievement = provider.achievements[index];
                return AchievementListItem(
                  achievement: achievement,
                  onDismissed: () {
                    // Panggil fungsi hapus di provider
                    provider.deleteAchievement(achievement.id);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => AddEditScreen()),
          );
        },
      ),
    );
  }
}