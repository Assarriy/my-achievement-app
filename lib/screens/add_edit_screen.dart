import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/achievement_model.dart';
import '../providers/achievement_provider.dart';
import '../services/image_service.dart';

class AddEditScreen extends StatefulWidget {
  final Achievement? achievementToEdit;

  const AddEditScreen({super.key, this.achievementToEdit});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _imageService = ImageService();

  late TextEditingController _titleController;
  late TextEditingController _categoryController;
  late TextEditingController _descController;
  
  DateTime _selectedDate = DateTime.now();
  File? _pickedImageFile;
  String? _existingImagePath;
  
  bool _isEditMode = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _animationController.forward();

    if (widget.achievementToEdit != null) {
      final ach = widget.achievementToEdit!;
      _isEditMode = true;
      
      _titleController = TextEditingController(text: ach.title);
      _categoryController = TextEditingController(text: ach.category);
      _descController = TextEditingController(text: ach.description);
      _selectedDate = ach.date;
      _existingImagePath = ach.imagePath;
    } else {
      _titleController = TextEditingController();
      _categoryController = TextEditingController();
      _descController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _categoryController.dispose();
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
              primary: Colors.red,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.grey[800]!,
            ),
            dialogBackgroundColor: Colors.white,
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
    if (!isValid) {
      return;
    }

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
          category: _categoryController.text,
          description: _descController.text,
          newImageFile: _pickedImageFile,
        );
      } else {
        await provider.addAchievement(
          title: _titleController.text,
          date: _selectedDate,
          category: _categoryController.text,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Widget _buildImagePreview() {
    Widget imagePreview = Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.red.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey[50],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_camera, color: Colors.red.withOpacity(0.7), size: 40),
          SizedBox(height: 8),
          Text(
            'Tambahkan\nFoto',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );

    if (_pickedImageFile != null) {
      imagePreview = ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.file(
          _pickedImageFile!,
          fit: BoxFit.cover,
          width: 150,
          height: 150,
        ),
      );
    } else if (_existingImagePath != null) {
      imagePreview = ClipRRect(
        borderRadius: BorderRadius.circular(15),
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
      curve: Curves.easeInOut,
      child: imagePreview,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputAction textInputAction = TextInputAction.next,
    int maxLines = 1,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: Colors.grey[800]),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        textInputAction: textInputAction,
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Prestasi' : 'Tambah Prestasi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.red,
        elevation: 2,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          if (_isLoading)
            Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            )
          else
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              child: IconButton(
                icon: Icon(Icons.save, color: Colors.white),
                onPressed: _saveForm,
              ),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Image Section ---
                    Center(
                      child: Column(
                        children: [
                          _buildImagePreview(),
                          SizedBox(height: 16),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.image, color: Colors.white),
                              label: Text(
                                'Pilih Foto',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: _pickImage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),

                    // --- Title Field ---
                    _buildTextField(
                      controller: _titleController,
                      label: 'Judul Prestasi',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Judul tidak boleh kosong';
                        }
                        return null;
                      },
                    ),

                    // --- Category Field ---
                    _buildTextField(
                      controller: _categoryController,
                      label: 'Kategori (Lomba, Sertifikat, Proyek)',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kategori tidak boleh kosong';
                        }
                        return null;
                      },
                    ),

                    // --- Date Picker ---
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tanggal Prestasi',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                DateFormat('d MMMM yyyy').format(_selectedDate),
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            child: ElevatedButton(
                              child: Text(
                                'Pilih Tanggal',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: _presentDatePicker,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- Description Field ---
                    _buildTextField(
                      controller: _descController,
                      label: 'Deskripsi Prestasi',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Deskripsi tidak boleh kosong';
                        }
                        return null;
                      },
                      maxLines: 4,
                    ),

                    // --- Save Button ---
                    SizedBox(height: 30),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: double.infinity,
                      child: ElevatedButton(
                        child: _isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Menyimpan...',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              )
                            : Text(
                                _isEditMode ? 'Update Prestasi' : 'Simpan Prestasi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        onPressed: _isLoading ? null : _saveForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
    );
  }
}
