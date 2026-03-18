import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../logic/category/category_cubit.dart';
import '../../logic/category/category_state.dart';
import '../../data/models/category_model.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление категориями'),
      ),
      body: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, state) {
          if (state.status == CategoryStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.categories.isEmpty) {
            return const Center(child: Text('Нет категорий'));
          }

          return ListView.builder(
            itemCount: state.categories.length,
            itemBuilder: (context, index) {
              final cat = state.categories[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(cat.color).withValues(alpha: 0.15),
                  child: Icon(
                    IconHelper.getIconFromCodePoint(cat.icon),
                    color: Color(cat.color),
                  ),
                ),
                title: Text(cat.name),
                subtitle: Text(cat.type == 'income' ? 'Доход' : 'Расход'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _showCategoryDialog(context, category: cat),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _confirmDelete(context, cat),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, CategoryModel category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить категорию?'),
        content: Text('Вы уверены, что хотите удалить "${category.name}"? Операции с этой категорией останутся, но категория будет помечена как удаленная.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              context.read<CategoryCubit>().deleteCategory(category.id);
              Navigator.pop(ctx);
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, {CategoryModel? category}) {
    final nameController = TextEditingController(text: category?.name);
    String type = category?.type ?? 'expense';
    int selectedColor = category?.color ?? Colors.blue.value;
    int selectedIcon = category?.icon ?? Icons.category.codePoint;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(category == null ? 'Новая категория' : 'Редактировать'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Название'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Расход'),
                        value: 'expense',
                        groupValue: type,
                        onChanged: (v) => setState(() => type = v!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Доход'),
                        value: 'income',
                        groupValue: type,
                        onChanged: (v) => setState(() => type = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Цвет'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    // Reds/Pinks
                    Colors.red,
                    Colors.red[300]!,
                    Colors.red[700]!,
                    Colors.pink,
                    Colors.pink[300]!,
                    Colors.pink[700]!,
                    // Purples
                    Colors.purple,
                    Colors.purple[300]!,
                    Colors.purple[700]!,
                    Colors.deepPurple,
                    Colors.deepPurple[300]!,
                    // Blues
                    Colors.indigo,
                    Colors.indigo[300]!,
                    Colors.blue,
                    Colors.blue[300]!,
                    Colors.blue[700]!,
                    Colors.lightBlue,
                    Colors.cyan,
                    Colors.cyan[700]!,
                    // Greens
                    Colors.teal,
                    Colors.teal[300]!,
                    Colors.green,
                    Colors.green[300]!,
                    Colors.green[700]!,
                    Colors.lightGreen,
                    Colors.lime,
                    // Yellows/Oranges
                    Colors.yellow[600]!,
                    Colors.amber,
                    Colors.orange,
                    Colors.orange[300]!,
                    Colors.deepOrange,
                    Colors.deepOrange[300]!,
                    // Browns/Greys
                    Colors.brown,
                    Colors.brown[300]!,
                    Colors.blueGrey,
                    Colors.grey,
                    Colors.grey[700]!,
                    Colors.black87,
                  ].map((color) {
                    return GestureDetector(
                      onTap: () => setState(() => selectedColor = color.value),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: selectedColor == color.value
                              ? Border.all(color: Colors.black, width: 2)
                              : null,
                        ),
                        child: selectedColor == color.value
                            ? const Icon(Icons.check, size: 18, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Text('Иконка'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: IconHelper.getAvailableIcons().map((icon) {
                    return GestureDetector(
                      onTap: () => setState(() => selectedIcon = icon.codePoint),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: selectedIcon == icon.codePoint
                              ? AppTheme.primaryColor.withValues(alpha: 0.1)
                              : Colors.grey[100],
                          border: Border.all(
                            color: selectedIcon == icon.codePoint
                                ? AppTheme.primaryColor
                                : Colors.transparent,
                            width: 2,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: 20,
                          color: selectedIcon == icon.codePoint
                              ? AppTheme.primaryColor
                              : Colors.grey[600],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                final cubit = context.read<CategoryCubit>();
                if (category == null) {
                  cubit.addCategory(CategoryModel(
                    id: const Uuid().v4(),
                    name: name,
                    icon: selectedIcon,
                    color: selectedColor,
                    type: type,
                  ));
                } else {
                  cubit.updateCategory(category.copyWith(
                    name: name,
                    type: type,
                    color: selectedColor,
                    icon: selectedIcon,
                  ));
                }
                Navigator.pop(ctx);
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}
