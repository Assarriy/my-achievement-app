import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/achievement_model.dart';
import '../providers/achievement_provider.dart';
import '../services/image_service.dart';

class AddEditScreen extends StatefulWidget {
  // Jika achievementToEdit tidak null, kita masuk mode Edit
  final Achievement? achievementToEdit;

  const AddEditScreen({Key? key, this.achievementToEdit}) : super(key: key);

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>(); // Kunci untuk validasi form
  final _imageService = ImageService(); // Instance service gambar

  // Controllers untuk setiap field
  late TextEditingController _titleController;
  late TextEditingController _categoryController;
  late TextEditingController _descController;
  
  DateTime _selectedDate = DateTime.now();
  File? _pickedImageFile; // Menyimpan file gambar YANG BARU dipilih
  String? _existingImagePath; // Menyimpan path gambar LAMA (saat mode edit)
  
  bool _isEditMode = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Cek apakah ini mode Edit
    if (widget.achievementToEdit != null) {
      final ach = widget.achievementToEdit!;
      _isEditMode = true;
      
      // Isi controller dengan data yang ada
      _titleController = TextEditingController(text: ach.title);
      _categoryController = TextEditingController(text: ach.category);
      _descController = TextEditingController(text: ach.description);
      _selectedDate = ach.date;
      _existingImagePath = ach.imagePath;
    } else {
      // Mode Tambah: controller kosong
      _titleController = TextEditingController();
      _categoryController = TextEditingController();
      _descController = TextEditingController();
    }
  }

  @override
  void dispose() {
    // Selalu dispose controller untuk menghindari memory leak
    _titleController.dispose();
    _categoryController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // Fungsi untuk menampilkan date picker
  Future<void> _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Fungsi untuk memilih gambar
  Future<void> _pickImage() async {
    final pickedFile = await _imageService.pickImage();
    if (pickedFile != null) {
      setState(() {
        _pickedImageFile = pickedFile; // Simpan file gambar baru
      });
    }
  }

  // Fungsi untuk menyimpan data (Add atau Edit)
  Future<void> _saveForm() async {
    // 1. Validasi form
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return; // Jika form tidak valid, jangan lanjutkan
    }

    // 2. Simpan form
    _formKey.currentState?.save();
    setState(() {
      _isLoading = true;
    });

    // 3. Ambil provider (gunakan .read() di dalam fungsi)
    final provider = context.read<AchievementProvider>();

    try {
      if (_isEditMode) {
        // Panggil fungsi UPDATE (pastikan Anda sudah menambahkannya di provider)
        await provider.updateAchievement(
          id: widget.achievementToEdit!.id,
          title: _titleController.text,
          date: _selectedDate,
          category: _categoryController.text,
          description: _descController.text,
          newImageFile: _pickedImageFile, // Kirim file baru jika ada
        );
      } else {
        // Panggil fungsi ADD
        await provider.addAchievement(
          title: _titleController.text,
          date: _selectedDate,
          category: _categoryController.text,
          description: _descController.text,
          tempImage: _pickedImageFile,
        );
      }
      
      // 5. Kembali ke halaman sebelumnya
      if (mounted) {
         Navigator.of(context).pop();
      }

    } catch (error) {
      // Tampilkan error jika gagal
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Widget untuk menampilkan preview gambar
    Widget imagePreview = Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: const Text('Belum ada foto', textAlign: TextAlign.center),
    );

    if (_pickedImageFile != null) {
      // 1. Prioritas: Tampilkan gambar baru yang dipilih
      imagePreview = Image.file(
        _pickedImageFile!,
        fit: BoxFit.cover,
        width: 150,
        height: 150,
      );
    } else if (_existingImagePath != null) {
      // 2. Jika tidak ada gambar baru, tampilkan gambar lama (mode edit)
      imagePreview = Image.file(
        File(_existingImagePath!),
        fit: BoxFit.cover,
        width: 150,
        height: 150,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Prestasi' : 'Tambah Prestasi'),
        actions: [
          // Tombol Simpan
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveForm,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Input Gambar ---
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: imagePreview,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.image),
                        label: const Text('Pilih Foto'),
                        onPressed: _pickImage,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // --- Input Judul ---
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Judul Prestasi'),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Judul tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // --- Input Kategori ---
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Kategori (Lomba, Sertifikat, Proyek)'),
                  textInputAction: TextInputAction.next,
                   validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kategori tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // --- Input Tanggal ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tanggal: ${DateFormat('d MMMM yyyy').format(_selectedDate)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    TextButton(
                      child: const Text('Pilih Tanggal'),
                      onPressed: _presentDatePicker,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // --- Input Deskripsi ---
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                   validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Deskripsi tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}