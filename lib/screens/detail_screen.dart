import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/achievement_provider.dart';
import 'add_edit_screen.dart'; // Import AddEditScreen

class DetailScreen extends StatefulWidget {
  final String id;
  final String title;
  final String description;
  final String imageUrl;

  const DetailScreen({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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

    _colorAnimation = ColorTween(
      begin: Color(0xFF667EEA).withOpacity(0.3),
      end: Color(0xFF667EEA),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    final provider = context.read<AchievementProvider>();
    provider.toggleFavorite(widget.id);
    
    final isFavorite = provider.getAchievementById(widget.id)?.isFavorite ?? false;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isFavorite ? Icons.favorite : Icons.favorite_border, 
              color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text(isFavorite 
              ? 'Added to Favorites!' 
              : 'Removed from Favorites!'),
          ],
        ),
        backgroundColor: isFavorite ? Colors.red : Color(0xFF667EEA),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToEditScreen() {
    final provider = context.read<AchievementProvider>();
    final achievement = provider.getAchievementById(widget.id);
    
    if (achievement != null) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => AddEditScreen(
            achievementToEdit: achievement,
          ),
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
          transitionDuration: Duration(milliseconds: 600),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Text('Achievement not found!'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _deleteAchievement() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Achievement',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${widget.title}"? This action cannot be undone.',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF667EEA)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _confirmDelete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    final provider = context.read<AchievementProvider>();
    provider.deleteAchievement(widget.id);
    
    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Achievement deleted successfully!'),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AchievementProvider>();
    final achievement = provider.getAchievementById(widget.id);
    final isFavorite = achievement?.isFavorite ?? false;

    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 320.0,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      // Hero Image
                      Hero(
                        tag: 'item-${widget.id}',
                        child: Container(
                          width: double.infinity,
                          height: 400,
                          decoration: BoxDecoration(
                            image: widget.imageUrl.isNotEmpty && 
                                  !widget.imageUrl.contains('placeholder')
                                ? DecorationImage(
                                    image: NetworkImage(widget.imageUrl),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            gradient: widget.imageUrl.isEmpty || 
                                    widget.imageUrl.contains('placeholder')
                                ? LinearGradient(
                                    colors: [
                                      Color(0xFF667EEA).withOpacity(0.1),
                                      Color(0xFF1E293B),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  )
                                : null,
                          ),
                          child: widget.imageUrl.isEmpty || 
                                widget.imageUrl.contains('placeholder')
                              ? Center(
                                  child: Icon(
                                    Icons.auto_awesome,
                                    size: 100,
                                    color: Color(0xFF667EEA).withOpacity(0.3),
                                  ),
                                )
                              : null,
                        ),
                      ),
                      
                      // Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Color(0xFF0F172A).withOpacity(0.9),
                              Colors.transparent,
                              Colors.transparent,
                            ],
                            stops: [0.1, 0.5, 1.0],
                          ),
                        ),
                      ),
                      
                      // Background Elements
                      Positioned(
                        top: 50,
                        right: -30,
                        child: AnimatedContainer(
                          duration: Duration(seconds: 20),
                          curve: Curves.linear,
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                (isFavorite ? Colors.red : Color(0xFF667EEA)).withOpacity(0.1),
                                Colors.transparent,
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),

                      // Favorite Badge
                      if (isFavorite)
                        Positioned(
                          top: 50,
                          left: 20,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.4),
                                    blurRadius: 15,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.favorite,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                actions: [
                  // Delete Button
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: _deleteAchievement,
                      ),
                    ),
                  ),
                  
                  // Share Button
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.share, color: Colors.white),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.share, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text('Share feature coming soon!'),
                                ],
                              ),
                              backgroundColor: Color(0xFF667EEA),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title Section
                              Row(
                                children: [
                                  ScaleTransition(
                                    scale: _scaleAnimation,
                                    child: Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isFavorite
                                            ? [
                                                Colors.red,
                                                Colors.red.withOpacity(0.7),
                                              ]
                                            : [
                                                Color(0xFF667EEA),
                                                Color(0xFF764BA2),
                                              ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (isFavorite ? Colors.red : Color(0xFF667EEA)).withOpacity(0.4),
                                            blurRadius: 15,
                                            offset: Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        isFavorite ? Icons.favorite : Icons.auto_awesome,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.title,
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: (isFavorite ? Colors.red : Color(0xFF667EEA)).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: (isFavorite ? Colors.red : Color(0xFF667EEA)).withOpacity(0.3),
                                            ),
                                          ),
                                          child: Text(
                                            isFavorite ? 'FAVORITE ACHIEVEMENT' : 'ACHIEVEMENT',
                                            style: TextStyle(
                                              color: isFavorite ? Colors.red : Color(0xFF667EEA),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 32),

                              // Animated Divider
                              Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      isFavorite ? Colors.red : Color(0xFF667EEA),
                                      (isFavorite ? Colors.red : Color(0xFF667EEA)).withOpacity(0.3),
                                      Colors.transparent,
                                    ],
                                    stops: [0.0, 0.5, 1.0],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),

                              SizedBox(height: 32),

                              // Description Section
                              ScaleTransition(
                                scale: _scaleAnimation,
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF1E293B),
                                        Color(0xFF334155).withOpacity(0.5),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isFavorite ? Colors.red.withOpacity(0.3) : Color(0xFF475569),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: (isFavorite ? Colors.red : Color(0xFF667EEA)).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Icon(Icons.description, 
                                              color: isFavorite ? Colors.red : Color(0xFF667EEA), size: 24),
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            'Description',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18,
                                              color: Colors.white,
                                              letterSpacing: -0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        widget.description,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF94A3B8),
                                          height: 1.7,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: 40),

                              // Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: AnimatedBuilder(
                                      animation: _colorAnimation,
                                      builder: (context, child) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(16),
                                            gradient: LinearGradient(
                                              colors: isFavorite
                                                ? [
                                                    Colors.red,
                                                    Colors.red.withOpacity(0.7),
                                                  ]
                                                : [
                                                    Color(0xFF667EEA),
                                                    Color(0xFF764BA2),
                                                  ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: (isFavorite ? Colors.red : _colorAnimation.value!).withOpacity(0.5),
                                                blurRadius: 20,
                                                offset: Offset(0, 8),
                                              ),
                                            ],
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: _toggleFavorite,
                                              borderRadius: BorderRadius.circular(16),
                                              splashColor: Colors.white.withOpacity(0.2),
                                              highlightColor: Colors.white.withOpacity(0.1),
                                              child: Container(
                                                padding: EdgeInsets.symmetric(vertical: 18),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    AnimatedSwitcher(
                                                      duration: Duration(milliseconds: 300),
                                                      child: Icon(
                                                        isFavorite 
                                                            ? Icons.favorite 
                                                            : Icons.favorite_border,
                                                        key: ValueKey(isFavorite),
                                                        color: Colors.white,
                                                        size: 24,
                                                      ),
                                                    ),
                                                    SizedBox(width: 12),
                                                    Text(
                                                      isFavorite 
                                                          ? 'In Favorites' 
                                                          : 'Add to Favorites',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w700,
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  ScaleTransition(
                                    scale: _scaleAnimation,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xFF1E293B),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Color(0xFF475569),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.3),
                                            blurRadius: 10,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: _navigateToEditScreen,
                                          borderRadius: BorderRadius.circular(16),
                                          child: Container(
                                            padding: EdgeInsets.all(16),
                                            child: Icon(
                                              Icons.edit,
                                              color: Color(0xFF667EEA),
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 32),

                              // Additional Info Section
                              ScaleTransition(
                                scale: _scaleAnimation,
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF1E293B),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Color(0xFF475569),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildInfoItem(
                                        Icons.calendar_today, 
                                        'Date', 
                                        achievement?.date != null 
                                            ? _formatDate(achievement!.date) 
                                            : 'Unknown'
                                      ),
                                      _buildInfoItem(
                                        Icons.category, 
                                        'Category', 
                                        achievement?.category ?? 'General'
                                      ),
                                      _buildInfoItem(
                                        Icons.auto_awesome, 
                                        'Status', 
                                        isFavorite ? 'Favorite' : 'Standard'
                                      ),
                                    ],
                                  ),
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

  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xFF667EEA).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Color(0xFF667EEA), size: 20),
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

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }
}