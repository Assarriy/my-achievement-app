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
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _colorAnimation =
        ColorTween(
          begin: Color(0xFF667EEA).withOpacity(0.7),
          end: Color(0xFF667EEA),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOutCubic,
          ),
        );

    _slideAnimation = Tween<Offset>(begin: Offset(0.8, 0.0), end: Offset.zero)
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
                scale: _isHovered ? 1.03 : _scaleAnimation.value,
                child: Dismissible(
                  key: ValueKey(widget.achievement.id),
                  direction: DismissDirection.endToStart,
                  background: _buildDismissBackground(),
                  secondaryBackground: _buildDismissBackground(),
                  onDismissed: (direction) => widget.onDismissed(),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            0.3 * _fadeAnimation.value,
                          ),
                          blurRadius: _isHovered ? 25 : 15,
                          offset: Offset(0, _isHovered ? 12 : 6),
                          spreadRadius: _isHovered ? 1 : 0,
                        ),
                        BoxShadow(
                          color: Color(
                            0xFF667EEA,
                          ).withOpacity(0.1 * _fadeAnimation.value),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
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
                                        id: widget.achievement.id, // Kirim ID
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
                                          scale:
                                              Tween<double>(
                                                begin: 0.9,
                                                end: 1.0,
                                              ).animate(
                                                CurvedAnimation(
                                                  parent: animation,
                                                  curve: Curves.easeOutCubic,
                                                ),
                                              ),
                                          child: FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          ),
                                        );
                                      },
                                  transitionDuration: Duration(
                                    milliseconds: 500,
                                  ),
                                ),
                              );
                            },
                        splashColor: Color(0xFF667EEA).withOpacity(0.2),
                        highlightColor: Color(0xFF667EEA).withOpacity(0.1),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF1E293B),
                                Color(0xFF334155).withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _isHovered
                                  ? Color(0xFF667EEA).withOpacity(0.5)
                                  : Color(0xFF475569).withOpacity(0.5),
                              width: _isHovered ? 2 : 1.5,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Background decorative elements
                              Positioned(
                                right: -15,
                                top: -15,
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 400),
                                  width: _isHovered ? 90 : 70,
                                  height: _isHovered ? 90 : 70,
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      colors: [
                                        Color(0xFF667EEA).withOpacity(0.1),
                                        Colors.transparent,
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),

                              // Floating particles
                              Positioned(
                                top: 20,
                                left: -5,
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF667EEA).withOpacity(0.6),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    // Leading Icon with Animation
                                    AnimatedBuilder(
                                      animation: _colorAnimation,
                                      builder: (context, child) {
                                        return Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                _colorAnimation.value!,
                                                Color(0xFF764BA2),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: _colorAnimation.value!
                                                    .withOpacity(0.5),
                                                blurRadius: _isHovered
                                                    ? 15
                                                    : 10,
                                                offset: Offset(2, 2),
                                              ),
                                            ],
                                          ),
                                          child: AnimatedContainer(
                                            duration: Duration(
                                              milliseconds: 300,
                                            ),
                                            child: Icon(
                                              Icons.auto_awesome,
                                              color: Colors.white,
                                              size: _isHovered ? 26 : 22,
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    const SizedBox(width: 20),

                                    // Content
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          AnimatedDefaultTextStyle(
                                            duration: Duration(
                                              milliseconds: 300,
                                            ),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: _isHovered ? 18 : 16,
                                              letterSpacing: -0.3,
                                              shadows: _isHovered
                                                  ? [
                                                      Shadow(
                                                        blurRadius: 15,
                                                        color: Color(
                                                          0xFF667EEA,
                                                        ).withOpacity(0.4),
                                                        offset: Offset(2, 2),
                                                      ),
                                                    ]
                                                  : [],
                                            ),
                                            child: Text(
                                              widget.achievement.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),

                                          const SizedBox(height: 8),

                                          Text(
                                            widget.achievement.description,
                                            style: TextStyle(
                                              color: Color(0xFF94A3B8),
                                              fontSize: 14,
                                              height: 1.4,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),

                                          const SizedBox(height: 12),

                                          Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: Color(
                                                    0xFF667EEA,
                                                  ).withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  Icons.calendar_today,
                                                  color: Color(0xFF667EEA),
                                                  size: 14,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                _formatDate(
                                                  widget.achievement.date,
                                                ),
                                                style: TextStyle(
                                                  color: Color(0xFF64748B),
                                                  fontSize: 13,
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
                                                        horizontal: 12,
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Color(
                                                          0xFF667EEA,
                                                        ).withOpacity(0.2),
                                                        Color(
                                                          0xFF764BA2,
                                                        ).withOpacity(0.1),
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    border: Border.all(
                                                      color: Color(
                                                        0xFF667EEA,
                                                      ).withOpacity(0.3),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    widget.achievement.category,
                                                    style: TextStyle(
                                                      color: Color(0xFF667EEA),
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 16),

                                    // Animated Arrow
                                    AnimatedContainer(
                                      duration: Duration(milliseconds: 400),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: _isHovered
                                            ? Color(0xFF667EEA).withOpacity(0.2)
                                            : Colors.transparent,
                                        shape: BoxShape.circle,
                                        border: _isHovered
                                            ? Border.all(
                                                color: Color(
                                                  0xFF667EEA,
                                                ).withOpacity(0.3),
                                                width: 1.5,
                                              )
                                            : null,
                                      ),
                                      child: AnimatedRotation(
                                        duration: Duration(milliseconds: 400),
                                        turns: _isHovered ? 0.25 : 0,
                                        curve: Curves.easeInOutBack,
                                        child: Icon(
                                          Icons.arrow_forward_ios,
                                          color: Color(0xFF667EEA),
                                          size: 18,
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
                                      borderRadius: BorderRadius.circular(20),
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Color(0xFF667EEA).withOpacity(0.05),
                                          Colors.transparent,
                                          Colors.transparent,
                                        ],
                                        stops: [0.0, 0.3, 1.0],
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFDC2626).withOpacity(0.4),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.delete, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Text(
            "Delete",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 24),
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
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }
}
