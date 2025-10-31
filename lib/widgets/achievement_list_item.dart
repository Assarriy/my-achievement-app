import 'package:flutter/material.dart';
import '../models/achievement_model.dart';
import '../screens/detail_screen.dart';

class AchievementListItem extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback onDismissed;
  final VoidCallback? onTap;

  const AchievementListItem({
    super.key,
    required this.achievement,
    required this.onDismissed,
    this.onTap,
  });

  @override
  State<AchievementListItem> createState() => _AchievementListItemState();
}

class _AchievementListItemState extends State<AchievementListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _colorAnimation =
        ColorTween(
          begin: Color(0xFFE53935).withOpacity(0.7),
          end: Color(0xFFE53935),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    _slideAnimation = Tween<Offset>(begin: Offset(0.5, 0.0), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: _slideAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _isHovered ? 1.02 : _scaleAnimation.value,
                child: Dismissible(
                  key: ValueKey(widget.achievement.id),
                  direction: DismissDirection.endToStart,
                  background: _buildDismissBackground(),
                  secondaryBackground: _buildDismissBackground(),
                  onDismissed: (direction) => widget.onDismissed(),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Color(
                            0xFFE53935,
                          ).withOpacity(0.15 * _fadeAnimation.value),
                          blurRadius: 15,
                          offset: Offset(0, 6),
                          spreadRadius: _isHovered ? 2 : 0,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap:
                            widget.onTap ??
                            () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => DetailScreen(
                                        title: widget.achievement.title,
                                        description:
                                            widget.achievement.description,
                                        imageUrl:
                                            widget.achievement.imagePath ??
                                            'https://via.placeholder.com/600x400?text=No+Image',
                                      ),
                                  transitionsBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                        child,
                                      ) {
                                        return ScaleTransition(
                                          scale: animation,
                                          child: FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          ),
                                        );
                                      },
                                ),
                              );
                            },
                        splashColor: Color(0xFFE53935).withOpacity(0.2),
                        highlightColor: Color(0xFFE53935).withOpacity(0.1),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.95),
                                Colors.white.withOpacity(0.9),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Color(0xFFE53935).withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Background decorative elements
                              Positioned(
                                right: -10,
                                top: -10,
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  width: _isHovered ? 80 : 60,
                                  height: _isHovered ? 80 : 60,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFE53935).withOpacity(0.05),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Leading Icon with Animation
                                    AnimatedBuilder(
                                      animation: _colorAnimation,
                                      builder: (context, child) {
                                        return Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                _colorAnimation.value!,
                                                Color(0xFFFF5722),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: _colorAnimation.value!
                                                    .withOpacity(0.4),
                                                blurRadius: 8,
                                                offset: Offset(2, 2),
                                              ),
                                            ],
                                          ),
                                          child: AnimatedContainer(
                                            duration: Duration(
                                              milliseconds: 200,
                                            ),
                                            child: Icon(
                                              Icons.emoji_events,
                                              color: Colors.white,
                                              size: _isHovered ? 28 : 24,
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    const SizedBox(width: 16),

                                    // Content
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          AnimatedDefaultTextStyle(
                                            duration: Duration(
                                              milliseconds: 200,
                                            ),
                                            style: TextStyle(
                                              color: Color(0xFFE53935),
                                              fontWeight: FontWeight.bold,
                                              fontSize: _isHovered ? 18 : 16,
                                              shadows: [
                                                if (_isHovered)
                                                  Shadow(
                                                    blurRadius: 10,
                                                    color: Color(
                                                      0xFFE53935,
                                                    ).withOpacity(0.3),
                                                    offset: Offset(1, 1),
                                                  ),
                                              ],
                                            ),
                                            child: Text(
                                              widget.achievement.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),

                                          const SizedBox(height: 6),

                                          Text(
                                            widget.achievement.description,
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 14,
                                              height: 1.3,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),

                                          const SizedBox(height: 8),

                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today,
                                                color: Color(
                                                  0xFFE53935,
                                                ).withOpacity(0.7),
                                                size: 14,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _formatDate(
                                                  widget.achievement.date,
                                                ),
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),

                                              const Spacer(),

                                              // Category badge jika ada
                                              if (widget
                                                      .achievement
                                                      .category
                                                      .isNotEmpty)
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Color(
                                                      0xFFE53935,
                                                    ).withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    border: Border.all(
                                                      color: Color(
                                                        0xFFE53935,
                                                      ).withOpacity(0.3),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    widget
                                                        .achievement
                                                        .category,
                                                    style: TextStyle(
                                                      color: Color(0xFFE53935),
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    // Animated Arrow
                                    AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: _isHovered
                                            ? Color(0xFFE53935).withOpacity(0.1)
                                            : Colors.transparent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: AnimatedRotation(
                                        duration: Duration(milliseconds: 300),
                                        turns: _isHovered ? 0.25 : 0,
                                        child: Icon(
                                          Icons.arrow_forward_ios,
                                          color: Color(0xFFE53935),
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Hover overlay
                              if (_isHovered)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Color(0xFFE53935).withOpacity(0.03),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE53935), Color(0xFFFF5252)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(Icons.delete, color: Colors.white, size: 24),
          const SizedBox(width: 16),
          Text(
            "Hapus",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }
}
