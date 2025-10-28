import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/achievement_provider.dart';
import '../widgets/achievement_list_item.dart';
import 'add_edit_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AchievementProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "My Achievements",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.red,
        elevation: 2,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [

          // Tombol Profile
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => ProfileScreen()),
              );
            },
          ),
          // Tombol Sortir
          PopupMenuButton<SortType>(
            icon: Icon(Icons.sort, color: Colors.white),
            onSelected: (SortType result) {
              _showSortAnimation(context);
              provider.sortAchievements(result);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortType>>[
              PopupMenuItem<SortType>(
                value: SortType.byDate,
                child: Row(
                  children: [
                    Icon(Icons.date_range, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Urutkan berdasarkan Tanggal'),
                  ],
                ),
              ),
              PopupMenuItem<SortType>(
                value: SortType.byCategory,
                child: Row(
                  children: [
                    Icon(Icons.category, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Urutkan berdasarkan Kategori'),
                  ],
                ),
              ),
            ],
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Colors.red, width: 1),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFFEF2F2),
            ],
          ),
        ),
        child: provider.achievements.isEmpty
            ? _buildEmptyState()
            : _buildAchievementList(provider, context),
      ),
      floatingActionButton: _buildAnimatedFAB(context),
    );
  }

  // Widget untuk state kosong dengan animasi
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            child: Icon(
              Icons.emoji_events_outlined,
              size: 80,
              color: Colors.red.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 20),
          AnimatedOpacity(
            duration: Duration(milliseconds: 700),
            opacity: 1.0,
            child: Text(
              "Belum ada prestasi",
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          SizedBox(height: 8),
          AnimatedOpacity(
            duration: Duration(milliseconds: 900),
            opacity: 1.0,
            child: Text(
              "Ayo tambahkan prestasi pertama Anda!",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk list achievement dengan animasi
  Widget _buildAchievementList(AchievementProvider provider, BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      child: ListView.builder(
        itemCount: provider.achievements.length,
        itemBuilder: (ctx, index) {
          final achievement = provider.achievements[index];
          
          return AnimatedContainer(
            duration: Duration(milliseconds: 300 + (index * 100)),
            curve: Curves.easeOut,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Dismissible(
              key: Key(achievement.id),
              direction: DismissDirection.endToStart,
              background: Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.delete, color: Colors.white, size: 30),
              ),
              onDismissed: (direction) {
                _showDeleteAnimation(context);
                provider.deleteAchievement(achievement.id);
              },
              child: AchievementListItem(
                achievement: achievement,
                onDismissed: () {
                  _showDeleteAnimation(context);
                  provider.deleteAchievement(achievement.id);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // Floating Action Button dengan animasi
  Widget _buildAnimatedFAB(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.red,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => AddEditScreen()),
          );
        },
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // Animasi untuk sortir
  void _showSortAnimation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.red, size: 40),
              SizedBox(height: 10),
              Text(
                "Sortir Diubah",
                style: TextStyle(color: Colors.grey[800], fontSize: 16),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
    
    Future.delayed(Duration(milliseconds: 800), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  // Animasi untuk hapus
  void _showDeleteAnimation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.delete, color: Colors.white),
            SizedBox(width: 8),
            Text("Prestasi dihapus"),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  
}