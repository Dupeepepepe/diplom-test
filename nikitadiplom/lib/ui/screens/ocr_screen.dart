import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/ocr/ocr_cubit.dart';
import '../../logic/ocr/ocr_state.dart';
import '../../logic/transaction/transaction_cubit.dart';
import '../../logic/category/category_cubit.dart';
import '../../logic/category/category_state.dart';

class OcrScreen extends StatefulWidget {
  const OcrScreen({super.key});

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _categoryId;
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сканировать чек')),
      body: BlocConsumer<OcrCubit, OcrState>(
        listener: (context, state) {
          if (state.status == OcrStatus.extracted) {
            _amountController.text = state.extractedAmount ?? '';
            _descriptionController.text = state.extractedDescription ?? '';
            if (state.extractedDate != null) {
              final parts = state.extractedDate!.split('.');
              if (parts.length == 3) {
                final d = int.tryParse(parts[0]);
                final m = int.tryParse(parts[1]);
                final y = int.tryParse(parts[2]);
                if (d != null && m != null && y != null) {
                  setState(() => _date = DateTime(y, m, d));
                }
              }
            }
          }
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Image picker buttons
              if (state.status == OcrStatus.initial ||
                  state.status == OcrStatus.error) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(Icons.receipt_long,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'Сфотографируйте чек или выберите из галереи',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => context
                                    .read<OcrCubit>()
                                    .pickImage(fromCamera: true),
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Камера'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => context
                                    .read<OcrCubit>()
                                    .pickImage(fromCamera: false),
                                icon: const Icon(Icons.photo_library),
                                label: const Text('Галерея'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.status == OcrStatus.error)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      state.error ?? 'Ошибка',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],

              // Processing indicator
              if (state.status == OcrStatus.processing)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Распознавание текста...'),
                      ],
                    ),
                  ),
                ),

              // Extracted data
              if (state.status == OcrStatus.extracted) ...[
                // Image preview
                if (state.imagePath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(state.imagePath!),
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),

                // Editable fields
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Сумма',
                    suffixText: '₸',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration:
                      const InputDecoration(labelText: 'Описание'),
                ),
                const SizedBox(height: 12),

                // Category
                BlocBuilder<CategoryCubit, CategoryState>(
                  builder: (context, catState) {
                    return DropdownButtonFormField<String>(
                      initialValue: _categoryId,
                      decoration:
                          const InputDecoration(labelText: 'Категория'),
                      items: catState.expenseCategories
                          .map((cat) => DropdownMenuItem(
                                value: cat.id,
                                child: Text(cat.name),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _categoryId = v),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Date
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                      '${_date.day}.${_date.month.toString().padLeft(2, '0')}.${_date.year}'),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (d != null) setState(() => _date = d);
                  },
                ),
                const SizedBox(height: 8),

                // Recognized text expandable
                ExpansionTile(
                  title: const Text('Распознанный текст'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        state.fullText ?? '',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Save button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveExpense,
                    child: const Text('Сохранить как расход',
                        style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    context.read<OcrCubit>().reset();
                  },
                  child: const Text('Сканировать другой чек'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  void _saveExpense() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите корректную сумму')),
      );
      return;
    }
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите категорию')),
      );
      return;
    }

    context.read<TransactionCubit>().addTransaction(
          amount: amount,
          type: 'expense',
          categoryId: _categoryId!,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          date: _date,
        );

    context.read<OcrCubit>().reset();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Расход добавлен')),
    );
    Navigator.pop(context);
  }
}
