import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/achievement_provider.dart';
import '../providers/user_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final achievementProvider = context.watch<AchievementProvider>();
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.currentUser;

    final totalAchievements = achievementProvider.achievements.length;
    final categories = achievementProvider.achievements.map((a) => a.category).toSet();
    final totalCategories = categories.length;

    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Color(0xFF1A1A1A),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              color: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: Column(
                children: [
                  // Avatar with subtle red accent
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color(0xFFFFEBEE),
                        width: 3,
                      ),
                    ),
                    child: user?.avatarPath != null
                        ? ClipOval(
                            child: Image.file(
                              File(user!.avatarPath!),
                              fit: BoxFit.cover,
                              width: 96,
                              height: 96,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 44,
                            color: Color(0xFFD32F2F),
                          ),
                  ),
                  const SizedBox(height: 20),
                  // Name
                  Text(
                    user?.name ?? 'User',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF0F0F0),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Email
                  Text(
                    user?.email ?? 'email@example.com',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFF0F0F0),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Stats Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 16),
                    child: Text(
                      'Statistics',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),

                  // Stats Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildModernStatCard(
                          icon: Icons.emoji_events_outlined,
                          value: '$totalAchievements',
                          label: 'Total',
                          index: 0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildModernStatCard(
                          icon: Icons.category_outlined,
                          value: '$totalCategories',
                          label: 'Categories',
                          index: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildModernStatCard(
                          icon: Icons.calendar_month_outlined,
                          value: _getAchievementsThisMonth(achievementProvider.achievements),
                          label: 'This Month',
                          index: 2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildModernStatCard(
                          icon: Icons.trending_up_outlined,
                          value: _getAveragePerWeek(achievementProvider.achievements),
                          label: 'Avg/Week',
                          index: 3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Settings Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 24, bottom: 16),
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),

                  _buildModernSettingItem(
                    icon: Icons.edit_outlined,
                    title: 'Edit Profile',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    height: 1,
                    color: Color(0xFFF0F0F0),
                  ),

                  _buildModernSettingItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {},
                  ),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    height: 1,
                    color: Color(0xFFF0F0F0),
                  ),

                  _buildModernSettingItem(
                    icon: Icons.security_outlined,
                    title: 'Privacy',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernStatCard({
    required IconData icon,
    required String value,
    required String label,
    required int index,
  }) {
    final redShades = [
      Color(0xFFD32F2F), // Primary red
      Color(0xFFC62828), // Darker red
      Color(0xFFE53935), // Bright red
      Color(0xFFEF5350), // Light red
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Color(0xFFF0F0F0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: redShades[index].withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: redShades[index],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: Color(0xFFFFEBEE),
      highlightColor: Color(0xFFFFEBEE).withOpacity(0.5),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 18,
                color: Color(0xFFD32F2F),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Color(0xFF999999),
            ),
          ],
        ),
      ),
    );
  }

  String _getAchievementsThisMonth(List achievements) {
    final now = DateTime.now();
    final thisMonth = achievements.where((a) =>
      a.date.year == now.year && a.date.month == now.month
    ).length;
    return '$thisMonth';
  }

  String _getAveragePerWeek(List achievements) {
    if (achievements.isEmpty) return '0';
    final totalWeeks = DateTime.now().difference(achievements.last.date).inDays / 7;
    if (totalWeeks <= 0) return '0';
    final average = (achievements.length / totalWeeks).toStringAsFixed(1);
    return average;
  }
}
