import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/achievement_model.dart';
import '../providers/achievement_provider.dart';
import '../providers/category_provider.dart'; // <-- Import provider kategori
import '../services/image_service.dart';
import 'manage_categories_screen.dart'; // <-- Import halaman manage

class AddEditScreen extends StatefulWidget {
  // Jika achievementToEdit tidak null, kita masuk mode Edit
  final Achievement? achievementToEdit;

  const AddEditScreen({Key? key, this.achievementToEdit}) : super(key: key);

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imageService = ImageService();

  // Controllers untuk setiap field
  late TextEditingController _titleController;
  late TextEditingController _descController;

  DateTime _selectedDate = DateTime.now();
  File? _pickedImageFile; // Menyimpan file gambar YANG BARU dipilih
  String? _existingImagePath; // Menyimpan path gambar LAMA (saat mode edit)

  bool _isEditMode = false;
  bool _isLoading = false;

  // Variabel baru untuk menyimpan nama kategori yang dipilih
  String? _selectedCategoryName;

  @override
  void initState() {
    super.initState();

    if (widget.achievementToEdit != null) {
      final ach = widget.achievementToEdit!;
      _isEditMode = true;

      _titleController = TextEditingController(text: ach.title);
      _descController = TextEditingController(text: ach.description);
      _selectedDate = ach.date;
      _existingImagePath = ach.imagePath;
      _selectedCategoryName = ach.category; // Set kategori yang ada
    } else {
      // Mode Tambah: controller kosong
      _titleController = TextEditingController();
      _descController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // Fungsi untuk menampilkan date picker
  Future<void> _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000), // Batas awal tanggal
      lastDate: DateTime.now(), // Tidak bisa memilih tanggal di masa depan
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
        _pickedImageFile = pickedFile;
      });
    }
  }

  // Fungsi untuk menyimpan data (Add atau Edit)
  Future<void> _saveForm() async {
    // 1. Validasi form
    final isValid = _formKey.currentState?.validate() ?? false;

    // 2. Validasi Kategori (pastikan satu dipilih)
    if (_selectedCategoryName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih satu kategori.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Hentikan jika kategori belum dipilih
    }

    if (!isValid) {
      return; // Hentikan jika form tidak valid
    }

    _formKey.currentState?.save();
    setState(() {
      _isLoading = true;
    });

    // 3. Ambil provider (gunakan .read() di dalam fungsi)
    final provider = context.read<AchievementProvider>();

    try {
      if (_isEditMode) {
        // Panggil fungsi UPDATE
        await provider.updateAchievement(
          id: widget.achievementToEdit!.id,
          title: _titleController.text,
          date: _selectedDate,
          category: _selectedCategoryName!, // Kirim kategori terpilih
          description: _descController.text,
          newImageFile: _pickedImageFile,
        );
      } else {
        // Panggil fungsi ADD
        await provider.addAchievement(
          title: _titleController.text,
          date: _selectedDate,
          category: _selectedCategoryName!, // Kirim kategori terpilih
          description: _descController.text,
          tempImage: _pickedImageFile,
        );
      }

      // 5. Kembali ke halaman sebelumnya
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $error')));
    }
  }

  // Widget untuk membangun daftar Category Chip
  Widget _buildCategoryChips() {
    // Ambil daftar kategori dari provider
    // Gunakan .watch() agar UI rebuild jika ada kategori baru
    final categories = context.watch<CategoryProvider>().categories;

    if (categories.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada kategori.\nSilakan tambahkan di halaman "Kelola".',
          textAlign: TextAlign.center,
        ),
      );
    }

    // Wrap akan otomatis memindahkan chip ke baris baru
    return Wrap(
      spacing: 8.0, // Jarak horizontal antar chip
      runSpacing: 4.0, // Jarak vertikal antar baris chip
      children: categories.map((category) {
        return ChoiceChip(
          label: Text(category.name),
          selected: _selectedCategoryName == category.name,
          onSelected: (isSelected) {
            setState(() {
              if (isSelected) {
                _selectedCategoryName = category.name;
              }
            });
          },
        );
      }).toList(),
    );
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
      // Prioritas 1: Tampilkan gambar baru yang dipilih
      imagePreview = Image.file(
        _pickedImageFile!,
        fit: BoxFit.cover,
        width: 150,
        height: 150,
      );
    } else if (_existingImagePath != null) {
      // Prioritas 2: Tampilkan gambar lama (mode edit)
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
              child: Center(
                child: CircularProgressIndicator(color: Colors.blue),
              ),
            )
          else
            IconButton(icon: const Icon(Icons.save), onPressed: _saveForm),
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
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.image),
                        label: const Text('Pilih Foto'),
                        onPressed: _pickImage,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // --- Input Judul ---
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Prestasi',
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Judul tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // --- Input Kategori (BARU) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kategori',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton(
                      child: const Text('Kelola'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => const ManageCategoriesScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                _buildCategoryChips(),

                // --- AKHIR INPUT KATEGORI ---
                const SizedBox(height: 24),

                // --- Input Tanggal ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tanggal: ${DateFormat('d MMMM yyyy').format(_selectedDate)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    OutlinedButton(
                      child: const Text('Pilih Tanggal'),
                      onPressed: _presentDatePicker,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // --- Input Deskripsi ---
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    alignLabelWithHint: true,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
