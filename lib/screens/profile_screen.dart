import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/achievement_provider.dart';
import '../providers/user_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeInOutCubic),
    ));

    _slideAnimation = Tween<double>(
      begin: 60.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.1, 0.6, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.9, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final achievementProvider = context.watch<AchievementProvider>();
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.currentUser;

    final totalAchievements = achievementProvider.achievements.length;
    final categories = achievementProvider.achievements.map((a) => a.category).toSet();
    final totalCategories = categories.length;

    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              // Modern App Bar
              SliverAppBar(
                expandedHeight: 240.0,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF667EEA),
                          Color(0xFF764BA2),
                          Color(0xFFF093FB),
                        ],
                        stops: [0.0, 0.6, 1.0],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Background Pattern
                        Positioned(
                          top: -50,
                          right: -50,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withOpacity(0.1),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        // Profile Content
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Transform.translate(
                                offset: Offset(0, _slideAnimation.value),
                                child: Opacity(
                                  opacity: _fadeAnimation.value,
                                  child: Row(
                                    children: [
                                      ScaleTransition(
                                        scale: _scaleAnimation,
                                        child: Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.3),
                                              width: 2,
                                            ),
                                          ),
                                          child: user?.avatarPath != null
                                              ? ClipOval(
                                                  child: Image.file(
                                                    File(user!.avatarPath!),
                                                    fit: BoxFit.cover,
                                                    width: 80,
                                                    height: 80,
                                                  ),
                                                )
                                              : Icon(
                                                  Icons.person,
                                                  size: 36,
                                                  color: Colors.white,
                                                ),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user?.name ?? 'User',
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white,
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              user?.email ?? 'email@example.com',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white.withOpacity(0.8),
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              SliverList(
                delegate: SliverChildListDelegate([
                  Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              // Stats Section
                              _buildSectionHeader('Statistics', Icons.analytics),
                              SizedBox(height: 16),
                              
                              // Stats Grid
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildModernStatCard(
                                      icon: Icons.auto_awesome,
                                      value: '$totalAchievements',
                                      label: 'Total',
                                      index: 0,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: _buildModernStatCard(
                                      icon: Icons.category,
                                      value: '$totalCategories',
                                      label: 'Categories',
                                      index: 1,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildModernStatCard(
                                      icon: Icons.calendar_month,
                                      value: _getAchievementsThisMonth(achievementProvider.achievements),
                                      label: 'This Month',
                                      index: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: _buildModernStatCard(
                                      icon: Icons.trending_up,
                                      value: _getAveragePerWeek(achievementProvider.achievements),
                                      label: 'Avg/Week',
                                      index: 3,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 32),

                              // Settings Section
                              _buildSectionHeader('Settings', Icons.settings),
                              SizedBox(height: 16),

                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Color(0xFF334155),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    _buildModernSettingItem(
                                      icon: Icons.edit,
                                      title: 'Edit Profile',
                                      subtitle: 'Update your personal information',
                                      onTap: () {
                                        Navigator.of(context).push(
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation, secondaryAnimation) => const EditProfileScreen(),
                                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                              return SlideTransition(
                                                position: Tween<Offset>(
                                                  begin: const Offset(1.0, 0.0),
                                                  end: Offset.zero,
                                                ).animate(CurvedAnimation(
                                                  parent: animation,
                                                  curve: Curves.easeInOutCubic,
                                                )),
                                                child: FadeTransition(
                                                  opacity: animation,
                                                  child: child,
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),

                                    Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 20),
                                      height: 1,
                                      color: Color(0xFF334155),
                                    ),

                                    _buildModernSettingItem(
                                      icon: Icons.notifications,
                                      title: 'Notifications',
                                      subtitle: 'Manage your notification preferences',
                                      onTap: () {},
                                    ),

                                    Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 20),
                                      height: 1,
                                      color: Color(0xFF334155),
                                    ),

                                    _buildModernSettingItem(
                                      icon: Icons.security,
                                      title: 'Privacy & Security',
                                      subtitle: 'Control your privacy settings',
                                      onTap: () {},
                                    ),

                                    Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 20),
                                      height: 1,
                                      color: Color(0xFF334155),
                                    ),

                                    _buildModernSettingItem(
                                      icon: Icons.help_outline,
                                      title: 'Help & Support',
                                      subtitle: 'Get help and contact support',
                                      onTap: () {},
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 24),

                              // Additional Info
                              Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Color(0xFF334155),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildInfoItem('Member Since', '2024', Icons.calendar_today),
                                    _buildInfoItem('Level', 'Pro', Icons.star),
                                    _buildInfoItem('Status', 'Active', Icons.circle),
                                  ],
                                ),
                              ),

                              SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFF667EEA), size: 22),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildModernStatCard({
    required IconData icon,
    required String value,
    required String label,
    required int index,
  }) {
    final gradientColors = [
      [Color(0xFF667EEA), Color(0xFF764BA2)],
      [Color(0xFFF093FB), Color(0xFFF5576C)],
      [Color(0xFF4FACFE), Color(0xFF00F2FE)],
      [Color(0xFF43E97B), Color(0xFF38F9D7)],
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors[index],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[index][0].withOpacity(0.4),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 22,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: Color(0xFF667EEA).withOpacity(0.1),
      highlightColor: Color(0xFF667EEA).withOpacity(0.05),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFF667EEA).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: Color(0xFF667EEA),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF667EEA).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Color(0xFF667EEA), size: 18),
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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