import 'package:flutter/material.dart';
import '../models/achievement_model.dart';
import '../screens/detail_screen.dart'; // Pastikan import ini ada

class AchievementListItem extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback onDismissed;
  final VoidCallback? onTap; // Tambahkan ini untuk navigasi

  const AchievementListItem({
    super.key,
    required this.achievement,
    required this.onDismissed,
    this.onTap, // Opsional
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: InkWell(
        // Efek ripple saat diklik
        borderRadius: BorderRadius.circular(12),
        onTap: onTap ?? () {
          // Default: navigasi ke DetailScreen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => DetailScreen(
                title: achievement.title,
                description: achievement.description,
                imageUrl: achievement.imagePath ??
                    'https://via.placeholder.com/600x400?text=No+Image',
              ),
            ),
          );
        },
        child: Card(
          elevation: 2,
          margin: EdgeInsets.zero,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.red.withOpacity(0.2), width: 1),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red, width: 1),
              ),
              child: const Icon(Icons.emoji_events, color: Colors.red, size: 24),
            ),
            title: Text(
              achievement.title,
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(achievement.date),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}