import 'package:flutter/material.dart';
import 'package:my_achievement_app/models/achievement_model.dart';


class AchievementListItem extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback onDismissed;

  const AchievementListItem({
<<<<<<< HEAD
    super.key,
=======
>>>>>>> 961fbbe4453ee5f8639c10a46595af62ea1dd736
    required this.achievement,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.red.withOpacity(0.2), width: 1),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          leading: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red, width: 1),
            ),
            child: Icon(Icons.emoji_events, color: Colors.red, size: 24),
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
              SizedBox(height: 4),
              Text(
                achievement.description,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                _formatDate(achievement.date),
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey[400],
            size: 16,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
