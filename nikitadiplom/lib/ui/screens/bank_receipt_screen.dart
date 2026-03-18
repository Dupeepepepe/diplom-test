import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import '../../logic/transaction/transaction_cubit.dart';
import '../../logic/category/category_cubit.dart';
import '../../logic/category/category_state.dart';

class BankReceiptScreen extends StatefulWidget {
  const BankReceiptScreen({super.key});

  @override
  State<BankReceiptScreen> createState() => _BankReceiptScreenState();
}

class _BankReceiptScreenState extends State<BankReceiptScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _recognizer = TextRecognizer();

  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _imagePath;
  String? _fullText;
  bool _isProcessing = false;
  bool _isExtracted = false;
  String? _categoryId;
  DateTime _date = DateTime.now();
  String _bankType = 'auto';

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _recognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Чек из банка')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!_isExtracted && !_isProcessing) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.account_balance,
                        size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Загрузите скриншот или фото чека из Kaspi / Halyk',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    // Bank type selector
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'auto', label: Text('Авто')),
                        ButtonSegment(value: 'kaspi', label: Text('Kaspi')),
                        ButtonSegment(value: 'halyk', label: Text('Halyk')),
                      ],
                      selected: {_bankType},
                      onSelectionChanged: (v) =>
                          setState(() => _bankType = v.first),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _pickAndProcess(true),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Камера'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickAndProcess(false),
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
          ],

          if (_isProcessing)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Анализ чека...'),
                  ],
                ),
              ),
            ),

          if (_isExtracted) ...[
            if (_imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(_imagePath!),
                    height: 200, fit: BoxFit.cover),
              ),
            const SizedBox(height: 16),

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
              decoration: const InputDecoration(labelText: 'Описание'),
            ),
            const SizedBox(height: 12),

            BlocBuilder<CategoryCubit, CategoryState>(
              builder: (context, catState) {
                return DropdownButtonFormField<String>(
                  initialValue: _categoryId,
                  decoration: const InputDecoration(labelText: 'Категория'),
                  items: catState.expenseCategories
                      .map((c) =>
                          DropdownMenuItem(value: c.id, child: Text(c.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _categoryId = v),
                );
              },
            ),
            const SizedBox(height: 12),

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

            ExpansionTile(
              title: const Text('Распознанный текст'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_fullText ?? '',
                      style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Сохранить как расход',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() {
                _isExtracted = false;
                _imagePath = null;
                _fullText = null;
              }),
              child: const Text('Загрузить другой чек'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickAndProcess(bool fromCamera) async {
    final image = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 1920,
    );
    if (image == null) return;

    setState(() {
      _isProcessing = true;
      _imagePath = image.path;
    });

    try {
      final inputImage = InputImage.fromFile(File(image.path));
      final result = await _recognizer.processImage(inputImage);
      final text = result.text;

      _fullText = text;
      _amountController.text = _extractBankAmount(text) ?? '';
      _descriptionController.text = _extractBankDescription(text) ?? '';
      final extractedDate = _extractBankDate(text);
      if (extractedDate != null) _date = extractedDate;

      setState(() {
        _isProcessing = false;
        _isExtracted = true;
      });
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  String? _extractBankAmount(String text) {
    // Kaspi patterns
    final kaspiPatterns = [
      RegExp(r'[-−]\s*(\d[\d\s]*)\s*₸', caseSensitive: false),
      RegExp(r'Сумма[:\s]*(\d[\d\s,.]*)', caseSensitive: false),
      RegExp(r'(\d{1,3}(?:[\s,]\d{3})*(?:[.,]\d{2})?)\s*₸'),
    ];
    // Halyk patterns
    final halykPatterns = [
      RegExp(r'Сумма[:\s]*(\d[\d\s,.]*)', caseSensitive: false),
      RegExp(r'Amount[:\s]*(\d[\d\s,.]*)', caseSensitive: false),
    ];

    final patterns = _bankType == 'kaspi'
        ? kaspiPatterns
        : _bankType == 'halyk'
            ? halykPatterns
            : [...kaspiPatterns, ...halykPatterns];

    for (final p in patterns) {
      final match = p.firstMatch(text);
      if (match != null) {
        String raw = match.group(1) ?? '';
        raw = raw.replaceAll(RegExp(r'\s'), '').replaceAll(',', '.');
        final value = double.tryParse(raw);
        if (value != null && value > 0) {
          return value.toStringAsFixed(0);
        }
      }
    }

    // Fallback: any large number
    final fallback = RegExp(r'(\d{1,3}(?:[\s,]\d{3})+)');
    final match = fallback.firstMatch(text);
    if (match != null) {
      String raw = match.group(1)!.replaceAll(RegExp(r'[\s,]'), '');
      return raw;
    }
    return null;
  }

  DateTime? _extractBankDate(String text) {
    final datePattern = RegExp(r'(\d{2})[./](\d{2})[./](\d{2,4})');
    final match = datePattern.firstMatch(text);
    if (match != null) {
      final d = int.tryParse(match.group(1)!);
      final m = int.tryParse(match.group(2)!);
      var y = int.tryParse(match.group(3)!);
      if (d != null && m != null && y != null) {
        if (y < 100) y += 2000;
        return DateTime(y, m, d);
      }
    }
    return null;
  }

  String? _extractBankDescription(String text) {
    // Try to find merchant/recipient name
    final patterns = [
      RegExp(r'(?:Получатель|Магазин|Merchant)[:\s]*(.+)',
          caseSensitive: false),
      RegExp(r'(?:Перевод|Оплата|Покупка)[:\s]*(.+)', caseSensitive: false),
    ];
    for (final p in patterns) {
      final match = p.firstMatch(text);
      if (match != null) {
        final desc = match.group(1)?.trim();
        if (desc != null && desc.isNotEmpty) {
          return desc.length > 50 ? desc.substring(0, 50) : desc;
        }
      }
    }
    return null;
  }

  void _save() {
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Расход добавлен')),
    );
    Navigator.pop(context);
  }
}
