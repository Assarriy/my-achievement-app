import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../providers/category_provider.dart';

class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({Key? key}) : super(key: key);

  // Fungsi untuk menampilkan dialog Add/Edit
  void _showCategoryDialog(BuildContext context, {Category? category}) {
    final provider = context.read<CategoryProvider>();
    final controller = TextEditingController(text: category?.name ?? '');
    final isEditing = category != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Edit Kategori' : 'Kategori Baru'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: 'Nama Kategori'),
        ),
        actions: [
          TextButton(
            child: Text('Batal'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text('Simpan'),
            onPressed: () {
              final name = controller.text;
              if (name.isNotEmpty) {
                if (isEditing) {
                  provider.updateCategory(category.id, name);
                } else {
                  provider.addCategory(name);
                }
                Navigator.of(ctx).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan .watch() agar UI update saat ada perubahan
    final categoryProvider = context.watch<CategoryProvider>();

    return Scaffold(
      appBar: AppBar(title: Text('Kelola Kategori')),
      body: ListView.builder(
        itemCount: categoryProvider.categories.length,
        itemBuilder: (ctx, index) {
          final category = categoryProvider.categories[index];
          return ListTile(
            title: Text(category.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tombol Edit
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () =>
                      _showCategoryDialog(context, category: category),
                ),
                // Tombol Hapus
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Tampilkan dialog konfirmasi hapus
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Hapus Kategori?'),
                        content: Text(
                          'Anda yakin ingin menghapus "${category.name}"?',
                        ),
                        actions: [
                          TextButton(
                            child: Text('Batal'),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                          TextButton(
                            child: Text(
                              'Hapus',
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () {
                              categoryProvider.deleteCategory(category.id);
                              Navigator.of(ctx).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showCategoryDialog(context),
      ),
    );
  }
}
