import 'dart:io';
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

  const AddEditScreen({Key? key, this.achievementToEdit}) : super(key: key);

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
  File? _pickedImageFile;
  String? _existingImagePath;
  String? _selectedCategoryName;

  bool _isEditMode = false;
  bool _isLoading = false;

  // Animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    ));

    _colorAnimation = ColorTween(
      begin: Color(0xFFE53935).withOpacity(0.5),
      end: Color(0xFFE53935),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
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
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFFE53935),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
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
    final pickedFile = await _imageService.pickImage();
    if (pickedFile != null) {
      setState(() {
        _pickedImageFile = pickedFile;
      });
    }
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (_selectedCategoryName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('Silakan pilih satu kategori.'),
            ],
          ),
          backgroundColor: Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      );
      return;
    }

    if (!isValid) return;

    _formKey.currentState?.save();
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
          newImageFile: _pickedImageFile,
        );
      } else {
        await provider.addAchievement(
          title: _titleController.text,
          date: _selectedDate,
          category: _selectedCategoryName!,
          description: _descController.text,
          tempImage: _pickedImageFile,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Gagal menyimpan: $error'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      );
    }
  }

  Widget _buildCategoryChips() {
    final categories = context.watch<CategoryProvider>().categories;

    if (categories.isEmpty) {
      return AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Color(0xFFFFF5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFFE53935).withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(Icons.category, color: Color(0xFFE53935).withOpacity(0.5), size: 40),
            SizedBox(height: 8),
            Text(
              'Tidak ada kategori.\nSilakan tambahkan di halaman "Kelola".',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: categories.map((category) {
        final isSelected = _selectedCategoryName == category.name;
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          child: FilterChip(
            label: Text(
              category.name,
              style: TextStyle(
                color: isSelected ? Colors.white : Color(0xFFE53935),
                fontWeight: FontWeight.w500,
              ),
            ),
            selected: isSelected,
            backgroundColor: Colors.white,
            selectedColor: Color(0xFFE53935),
            checkmarkColor: Colors.white,
            onSelected: (isSelected) {
              setState(() {
                if (isSelected) {
                  _selectedCategoryName = category.name;
                }
              });
            },
            elevation: isSelected ? 4 : 0,
            shadowColor: Color(0xFFE53935).withOpacity(0.3),
            shape: StadiumBorder(
              side: BorderSide(
                color: isSelected ? Color(0xFFE53935) : Colors.grey[300]!,
                width: 1.5,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImagePreview() {
    Widget imagePreview = Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(width: 2, color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_camera, size: 40, color: Colors.grey[400]),
          SizedBox(height: 8),
          Text('Belum ada foto', 
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    if (_pickedImageFile != null) {
      imagePreview = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          _pickedImageFile!,
          fit: BoxFit.cover,
          width: 150,
          height: 150,
        ),
      );
    } else if (_existingImagePath != null) {
      imagePreview = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(_existingImagePath!),
          fit: BoxFit.cover,
          width: 150,
          height: 150,
        ),
      );
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFE53935).withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: imagePreview,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Text(
                _isEditMode ? 'Edit Prestasi' : 'Tambah Prestasi',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            );
          },
        ),
        backgroundColor: Color(0xFFE53935),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE53935),
                Color(0xFFEF5350),
                Color(0xFFFF8A80),
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
            AnimatedBuilder(
              animation: _colorAnimation,
              builder: (context, child) {
                return IconButton(
                  icon: Icon(Icons.save, color: Colors.white),
                  onPressed: _saveForm,
                  tooltip: 'Simpan',
                );
              },
            ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFE53935).withOpacity(0.03),
                      Colors.white,
                      Colors.white,
                    ],
                  ),
                ),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image Section
                          Center(
                            child: Column(
                              children: [
                                _buildImagePreview(),
                                SizedBox(height: 16),
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  child: Material(
                                    color: Color(0xFFE53935),
                                    borderRadius: BorderRadius.circular(12),
                                    child: InkWell(
                                      onTap: _pickImage,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.camera_alt, 
                                              color: Colors.white, size: 20),
                                            SizedBox(width: 8),
                                            Text('Pilih Foto', 
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              )),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 32),

                          // Title Input
                          Text(
                            'Judul Prestasi',
                            style: TextStyle(
                              color: Color(0xFFE53935),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                hintText: 'Masukkan judul prestasi...',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Color(0xFFE53935),
                                    width: 2,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Judul tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 24),

                          // Category Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Kategori',
                                style: TextStyle(
                                  color: Color(0xFFE53935),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              AnimatedContainer(
                                duration: Duration(milliseconds: 300),
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
                                                curve: Curves.easeInOut,
                                              )),
                                              child: child,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.settings, 
                                            color: Color(0xFFE53935), size: 16),
                                          SizedBox(width: 4),
                                          Text('Kelola',
                                            style: TextStyle(
                                              color: Color(0xFFE53935),
                                              fontWeight: FontWeight.w600,
                                            )),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          _buildCategoryChips(),
                          SizedBox(height: 24),

                          // Date Section
                          Text(
                            'Tanggal Prestasi',
                            style: TextStyle(
                              color: Color(0xFFE53935),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Icon(Icons.calendar_today, 
                                color: Color(0xFFE53935)),
                              title: Text(
                                DateFormat('d MMMM yyyy').format(_selectedDate),
                                style: TextStyle(fontSize: 16),
                              ),
                              trailing: Material(
                                color: Color(0xFFE53935),
                                borderRadius: BorderRadius.circular(8),
                                child: InkWell(
                                  onTap: _presentDatePicker,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      'Pilih Tanggal',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey[300]!),
                              ),
                              tileColor: Colors.white,
                            ),
                          ),
                          SizedBox(height: 24),

                          // Description Input
                          Text(
                            'Deskripsi',
                            style: TextStyle(
                              color: Color(0xFFE53935),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _descController,
                              decoration: InputDecoration(
                                hintText: 'Ceritakan tentang prestasi Anda...',
                                alignLabelWithHint: true,
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Color(0xFFE53935),
                                    width: 2,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              maxLines: 4,
                              keyboardType: TextInputType.multiline,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Deskripsi tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 40),

                          // Save Button
                          AnimatedBuilder(
                            animation: _colorAnimation,
                            builder: (context, child) {
                              return Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _colorAnimation.value!.withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: _colorAnimation.value,
                                  borderRadius: BorderRadius.circular(16),
                                  child: InkWell(
                                    onTap: _saveForm,
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      child: Center(
                                        child: _isLoading
                                            ? SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                ),
                                              )
                                            : Text(
                                                _isEditMode ? 'UPDATE PRESTASI' : 'SIMPAN PRESTASI',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  letterSpacing: 1.2,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
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
}