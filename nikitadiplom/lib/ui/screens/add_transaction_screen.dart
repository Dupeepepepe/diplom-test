import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../data/models/transaction_model.dart';
import '../../logic/transaction/transaction_cubit.dart';
import '../../logic/category/category_cubit.dart';
import '../../logic/category/category_state.dart';
import '../../logic/settings/settings_cubit.dart';
import 'manage_categories_screen.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _type = 'expense';
  String? _categoryId;
  DateTime _date = DateTime.now();

  bool get isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final tx = widget.transaction!;
      _amountController.text = tx.amount.toStringAsFixed(0);
      _descriptionController.text = tx.description ?? '';
      _type = tx.type;
      _categoryId = tx.categoryId;
      _date = tx.date;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Редактировать' : 'Новая операция'),
      ),
      body: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, catState) {
          final categories = _type == 'income'
              ? catState.incomeCategories
              : catState.expenseCategories;

          // Reset category if switching type and current cat doesn't match
          if (_categoryId != null &&
              !categories.any((c) => c.id == _categoryId)) {
            _categoryId = null;
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Type toggle
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: _TypeButton(
                            label: 'Расход',
                            isSelected: _type == 'expense',
                            color: AppTheme.expenseColor,
                            onTap: () => setState(() => _type = 'expense'),
                          ),
                        ),
                        Expanded(
                          child: _TypeButton(
                            label: 'Доход',
                            isSelected: _type == 'income',
                            color: AppTheme.incomeColor,
                            onTap: () => setState(() => _type = 'income'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Amount
                BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (context, settingsState) {
                    return TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Сумма',
                        suffixText: settingsState.currency,
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите сумму';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Некорректная сумма';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Category selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Категория',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ManageCategoriesScreen()),
                        );
                      },
                      icon: const Icon(Icons.settings, size: 16),
                      label: const Text('Настроить',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((cat) {
                    final isSelected = _categoryId == cat.id;
                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            IconHelper.getIconFromCodePoint(cat.icon),
                            size: 16,
                            color:
                                isSelected ? Colors.white : Color(cat.color),
                          ),
                          const SizedBox(width: 4),
                          Text(cat.name),
                        ],
                      ),
                      selected: isSelected,
                      selectedColor: Color(cat.color),
                      onSelected: (_) {
                        setState(() => _categoryId = cat.id);
                      },
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Описание (необязательно)',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Date picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today,
                      color: AppTheme.primaryColor),
                  title: Text(
                    '${_date.day}.${_date.month.toString().padLeft(2, '0')}.${_date.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  subtitle: const Text('Дата операции'),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 24),

                // Save button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Text(
                      isEditing ? 'Сохранить' : 'Добавить',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date != null) {
      setState(() => _date = date);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите категорию')),
      );
      return;
    }

    final amount = double.parse(_amountController.text);
    final description = _descriptionController.text.trim();
    final cubit = context.read<TransactionCubit>();

    if (isEditing) {
      cubit.updateTransaction(widget.transaction!.copyWith(
        amount: amount,
        type: _type,
        categoryId: _categoryId,
        description: description.isEmpty ? null : description,
        date: _date,
      ));
    } else {
      cubit.addTransaction(
        amount: amount,
        type: _type,
        categoryId: _categoryId!,
        description: description.isEmpty ? null : description,
        date: _date,
      );
    }

    Navigator.pop(context);
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
