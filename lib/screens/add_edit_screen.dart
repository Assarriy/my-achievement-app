import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/achievement_model.dart';
import '../providers/achievement_provider.dart';
import '../providers/category_provider.dart';
import '../services/image_service.dart';
import 'manage_categories_screen.dart';

class AddEditScreen extends StatefulWidget {
  final Achievement? achievementToEdit;

  const AddEditScreen({super.key, this.achievementToEdit});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> 
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _imageService = ImageService();

  late TextEditingController _titleController;
  late TextEditingController _descController;

  DateTime _selectedDate = DateTime.now();
  Uint8List? _selectedImageBytes;
  String? _existingImagePath;
  String? _selectedCategoryName;

  bool _isEditMode = false;
  bool _isLoading = false;
  bool _isImageHovered = false;

  // Enhanced Animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize enhanced animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeInOutQuart),
    ));

    _slideAnimation = Tween<double>(
      begin: 60.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic),
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

    // Initialize form data
    if (widget.achievementToEdit != null) {
      final ach = widget.achievementToEdit!;
      _isEditMode = true;
      _titleController = TextEditingController(text: ach.title);
      _descController = TextEditingController(text: ach.description);
      _selectedDate = ach.date;
      _existingImagePath = ach.imagePath;
      _selectedCategoryName = ach.category;
    } else {
      _titleController = TextEditingController();
      _descController = TextEditingController();
      // Set default category jika ada
      final categories = context.read<CategoryProvider>().categories;
      if (categories.isNotEmpty) {
        _selectedCategoryName = categories.first.name;
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Color(0xFF667EEA),
              onPrimary: Colors.white,
              surface: Color(0xFF1E293B),
              onSurface: Colors.white,
              background: Color(0xFF0F172A),
            ),
            dialogBackgroundColor: Color(0xFF1E293B),
            cardColor: Color(0xFF1E293B),
          ),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Color(0xFF1E293B),
            child: child!,
          ),
        );
      },
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickImage() async {
    final imageBytes = await _imageService.pickImage();
    if (imageBytes != null) {
      setState(() {
        _selectedImageBytes = imageBytes;
        _existingImagePath = null; // Clear existing image path when new image is selected
      });
    }
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (_selectedCategoryName == null) {
      _showSnackBar(
        'Please select a category',
        Icons.category,
        Color(0xFF667EEA),
      );
      return;
    }

    if (!isValid) return;

    setState(() {
      _isLoading = true;
    });

    final provider = context.read<AchievementProvider>();

    try {
      if (_isEditMode) {
        await provider.updateAchievement(
          id: widget.achievementToEdit!.id,
          title: _titleController.text,
          date: _selectedDate,
          category: _selectedCategoryName!,
          description: _descController.text,
          newImageBytes: _selectedImageBytes,
        );
        
        _showSnackBar(
          'Achievement updated successfully!',
          Icons.check_circle,
          Colors.green,
        );
      } else {
        await provider.addAchievement(
          title: _titleController.text,
          date: _selectedDate,
          category: _selectedCategoryName!,
          description: _descController.text,
          imageBytes: _selectedImageBytes,
        );
        
        _showSnackBar(
          'Achievement created successfully!',
          Icons.check_circle,
          Colors.green,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar(
        'Failed to save: $error',
        Icons.error,
        Colors.red,
      );
    }
  }

  void _showSnackBar(String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _removeImage() {
    setState(() {
      _selectedImageBytes = null;
      _existingImagePath = null;
    });
  }

  Widget _buildCategoryChips() {
    final categories = context.watch<CategoryProvider>().categories;

    if (categories.isEmpty) {
      return AnimatedContainer(
        duration: Duration(milliseconds: 500),
        padding: EdgeInsets.all(24),
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1E293B),
              Color(0xFF334155).withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color(0xFF667EEA).withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF667EEA).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.category, 
                color: Color(0xFF667EEA), 
                size: 40,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'No Categories Available',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add categories to organize your achievements',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF667EEA),
                    Color(0xFF764BA2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF667EEA).withOpacity(0.4),
                    blurRadius: 15,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => ManageCategoriesScreen(),
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
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.settings, color: Colors.white, size: 20),
                        SizedBox(width: 12),
                        Text(
                          'Manage Categories',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: categories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final isSelected = _selectedCategoryName == category.name;
            
            return AnimatedContainer(
              duration: Duration(milliseconds: 400 + (index * 100)),
              curve: Curves.easeOutCubic,
              child: FilterChip(
                label: Text(
                  category.name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                    fontSize: isSelected ? 14 : 13,
                  ),
                ),
                selected: isSelected,
                backgroundColor: Color(0xFF334155),
                selectedColor: Color(0xFF667EEA),
                checkmarkColor: Colors.white,
                onSelected: (isSelected) {
                  setState(() {
                    if (isSelected) {
                      _selectedCategoryName = category.name;
                    }
                  });
                },
                elevation: isSelected ? 6 : 2,
                shadowColor: Color(0xFF667EEA).withOpacity(isSelected ? 0.4 : 0.1),
                shape: StadiumBorder(
                  side: BorderSide(
                    color: isSelected ? Color(0xFF667EEA) : Color(0xFF475569),
                    width: isSelected ? 2 : 1.5,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                avatar: isSelected ? Icon(Icons.check, size: 18, color: Colors.white) : null,
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF475569), width: 1.5),
              color: Color(0xFF1E293B),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => ManageCategoriesScreen(),
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
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.settings, color: Color(0xFF667EEA), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Manage Categories',
                        style: TextStyle(
                          color: Color(0xFF667EEA),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    final hasImage = _selectedImageBytes != null || (_existingImagePath != null && _existingImagePath!.isNotEmpty);

    return Stack(
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isImageHovered = true),
          onExit: (_) => setState(() => _isImageHovered = false),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isImageHovered ? Color(0xFF667EEA) : Color(0xFF334155),
                width: _isImageHovered ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_isImageHovered ? 0.5 : 0.3),
                  blurRadius: _isImageHovered ? 25 : 15,
                  offset: Offset(0, _isImageHovered ? 10 : 5),
                  spreadRadius: _isImageHovered ? 2 : 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(20),
                splashColor: Color(0xFF667EEA).withOpacity(0.3),
                highlightColor: Color(0xFF667EEA).withOpacity(0.1),
                child: Stack(
                  children: [
                    Center(
                      child: _buildImageContent(),
                    ),
                    if (_isImageHovered)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Color(0xFF667EEA).withOpacity(0.1),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFF667EEA).withOpacity(0.05),
                                Color(0xFF667EEA).withOpacity(0.15),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  color: Color(0xFF667EEA),
                                  size: 40,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  hasImage ? 'Change Image' : 'Select Image',
                                  style: TextStyle(
                                    color: Color(0xFF667EEA),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
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
        
        // Remove Image Button
        if (hasImage)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: _removeImage,
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageContent() {
    if (_selectedImageBytes != null) {
      // Gambar yang baru dipilih (dari memory)
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.memory(
          _selectedImageBytes!,
          fit: BoxFit.cover,
          width: 180,
          height: 180,
        ),
      );
    } else if (_existingImagePath != null && _existingImagePath!.isNotEmpty) {
      // Gambar yang sudah ada di database
      if (_existingImagePath!.startsWith('assets/')) {
        // Gambar dari assets
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            _existingImagePath!,
            fit: BoxFit.cover,
            width: 180,
            height: 180,
            errorBuilder: (context, error, stackTrace) {
              return _buildImagePlaceholder();
            },
          ),
        );
      } else if (_existingImagePath!.startsWith('http')) {
        // Gambar dari network (URL)
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            _existingImagePath!,
            fit: BoxFit.cover,
            width: 180,
            height: 180,
            errorBuilder: (context, error, stackTrace) {
              return _buildImagePlaceholder();
            },
          ),
        );
      } else {
        // Untuk local file path di web, gunakan placeholder
        return _buildImagePlaceholder();
      }
    } else {
      // Placeholder
      return _buildImagePlaceholder();
    }
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.photo_camera, size: 50, color: Color(0xFF64748B)),
        SizedBox(height: 12),
        Text('No Image', 
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
        ),
        SizedBox(height: 4),
        Text('Tap to select',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return CustomScrollView(
            physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              // Enhanced Modern App Bar
              SliverAppBar(
                expandedHeight: 200.0,
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
                        // Animated Background Elements
                        Positioned(
                          top: -60,
                          right: -60,
                          child: AnimatedContainer(
                            duration: Duration(seconds: 20),
                            curve: Curves.linear,
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withOpacity(0.15),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        // Content
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
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.3),
                                            ),
                                          ),
                                          child: Icon(
                                            _isEditMode ? Icons.edit : Icons.add,
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
                                              _isEditMode ? "Edit Achievement" : "New Achievement",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 28,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              _isEditMode 
                                                  ? "Update your achievement details"
                                                  : "Create a new achievement to track your progress",
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.8),
                                                fontSize: 14,
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
                actions: [
                  if (_isLoading)
                    Padding(
                      padding: EdgeInsets.only(right: 16.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  else
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: IconButton(
                        icon: Icon(Icons.save, color: Colors.white),
                        onPressed: _saveForm,
                        tooltip: 'Save Achievement',
                      ),
                    ),
                ],
              ),

              // Form Content
              SliverList(
                delegate: SliverChildListDelegate([
                  Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFF0F172A),
                                Color(0xFF1E293B),
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image Section
                                  Center(child: _buildImagePreview()),
                                  SizedBox(height: 32),

                                  // Title Input
                                  _buildFormField(
                                    label: 'Achievement Title',
                                    hint: 'Enter your achievement title...',
                                    controller: _titleController,
                                    icon: Icons.title,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Title is required';
                                      }
                                      if (value.length < 3) {
                                        return 'Title must be at least 3 characters long';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 24),

                                  // Category Section
                                  _buildSectionHeader('Category', Icons.category),
                                  SizedBox(height: 16),
                                  _buildCategoryChips(),
                                  SizedBox(height: 24),

                                  // Date Section
                                  _buildSectionHeader('Achievement Date', Icons.calendar_today),
                                  SizedBox(height: 12),
                                  _buildDatePicker(),
                                  SizedBox(height: 24),

                                  // Description Input
                                  _buildFormField(
                                    label: 'Description',
                                    hint: 'Tell us about your achievement...',
                                    controller: _descController,
                                    icon: Icons.description,
                                    maxLines: 4,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Description is required';
                                      }
                                      if (value.length < 10) {
                                        return 'Description must be at least 10 characters long';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 40),

                                  // Action Buttons
                                  Row(
                                    children: [
                                      // Cancel Button
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: Color(0xFF475569), width: 2),
                                            color: Color(0xFF1E293B),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.3),
                                                blurRadius: 15,
                                                offset: Offset(0, 6),
                                              ),
                                            ],
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.of(context).pop();
                                              },
                                              borderRadius: BorderRadius.circular(16),
                                              child: Container(
                                                padding: EdgeInsets.symmetric(vertical: 18),
                                                child: Center(
                                                  child: Text(
                                                    'CANCEL',
                                                    style: TextStyle(
                                                      color: Color(0xFF94A3B8),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      letterSpacing: 1.2,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      // Save Button
                                      Expanded(
                                        child: AnimatedBuilder(
                                          animation: _colorAnimation,
                                          builder: (context, child) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(16),
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Color(0xFF667EEA),
                                                    Color(0xFF764BA2),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: _colorAnimation.value!.withOpacity(0.5),
                                                    blurRadius: 25,
                                                    offset: Offset(0, 10),
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              ),
                                              child: Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTap: _saveForm,
                                                  borderRadius: BorderRadius.circular(16),
                                                  splashColor: Colors.white.withOpacity(0.2),
                                                  highlightColor: Colors.white.withOpacity(0.1),
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(vertical: 18),
                                                    child: Center(
                                                      child: _isLoading
                                                          ? SizedBox(
                                                              height: 24,
                                                              width: 24,
                                                              child: CircularProgressIndicator(
                                                                strokeWidth: 3,
                                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                              ),
                                                            )
                                                          : Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Icon(Icons.save, color: Colors.white, size: 20),
                                                                SizedBox(width: 12),
                                                                Text(
                                                                  _isEditMode ? 'UPDATE' : 'CREATE',
                                                                  style: TextStyle(
                                                                    color: Colors.white,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 16,
                                                                    letterSpacing: 1.2,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                ],
                              ),
                            ),
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

  Widget _buildFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required String? Function(String?) validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            style: TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 15),
              filled: true,
              fillColor: Color(0xFF1E293B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Color(0xFF667EEA),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: maxLines > 1 ? 16 : 18),
              prefixIcon: Icon(icon, color: Color(0xFF667EEA), size: 22),
            ),
            maxLines: maxLines,
            textInputAction: maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xFF667EEA).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.calendar_today, color: Color(0xFF667EEA), size: 22),
        ),
        title: Text(
          DateFormat('EEEE, d MMMM yyyy').format(_selectedDate),
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Selected date',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
        trailing: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                Color(0xFF667EEA),
                Color(0xFF764BA2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF667EEA).withOpacity(0.4),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _presentDatePicker,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(
                  'Change Date',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        tileColor: Color(0xFF1E293B),
      ),
    );
  }
}