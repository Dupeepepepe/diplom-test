import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'ocr_state.dart';

class OcrCubit extends Cubit<OcrState> {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();

  OcrCubit() : super(const OcrState());

  Future<void> pickImage({required bool fromCamera}) async {
    emit(state.copyWith(status: OcrStatus.picking));
    try {
      final image = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (image == null) {
        emit(const OcrState());
        return;
      }
      emit(state.copyWith(
        status: OcrStatus.processing,
        imagePath: image.path,
      ));
      await _processImage(image.path);
    } catch (e) {
      emit(state.copyWith(
        status: OcrStatus.error,
        error: 'Ошибка при выборе изображения: $e',
      ));
    }
  }

  Future<void> _processImage(String path) async {
    try {
      final inputImage = InputImage.fromFile(File(path));
      final recognized = await _textRecognizer.processImage(inputImage);
      final text = recognized.text;

      final amount = _extractAmount(text);
      final date = _extractDate(text);
      final description = _extractDescription(text);

      emit(state.copyWith(
        status: OcrStatus.extracted,
        fullText: text,
        extractedAmount: amount,
        extractedDate: date,
        extractedDescription: description,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OcrStatus.error,
        error: 'Ошибка распознавания: $e',
      ));
    }
  }

  String? _extractAmount(String text) {
    // 1. Try to find explicit total keywords (Итог, Сумма, Total, etc.)
    final keywordPattern = RegExp(
        r'(?:Сумма|Итог|Итого|Total|Всего|К оплате|Total amount)\s*[:=]?\s*(\d{1,10}(?:[\s]\d{3})*(?:[.,]\d{2})?)',
        caseSensitive: false);
    final keywordMatches = keywordPattern.allMatches(text);
    if (keywordMatches.isNotEmpty) {
      double maxKeywordAmount = 0.0;
      for (final match in keywordMatches) {
        String raw = match.group(1) ?? '';
        raw = raw.replaceAll(RegExp(r'\s'), '').replaceAll(',', '.');
        final value = double.tryParse(raw);
        if (value != null && value > maxKeywordAmount) {
          maxKeywordAmount = value;
        }
      }
      if (maxKeywordAmount > 0) {
        return maxKeywordAmount.toStringAsFixed(maxKeywordAmount.truncateToDouble() == maxKeywordAmount ? 0 : 2);
      }
    }

    // 2. Look for amounts with currency symbols
    final currencyPattern = RegExp(
        r'(\d{1,10}(?:[\s]\d{3})*(?:[.,]\d{2})?)\s*(?:₸|тг|тенге|KZT)',
        caseSensitive: false);
    final currencyMatches = currencyPattern.allMatches(text);
    if (currencyMatches.isNotEmpty) {
      double maxCurrencyAmount = 0.0;
      for (final match in currencyMatches) {
        String raw = match.group(1) ?? '';
        raw = raw.replaceAll(RegExp(r'\s'), '').replaceAll(',', '.');
        final value = double.tryParse(raw);
        if (value != null && value > maxCurrencyAmount) {
          maxCurrencyAmount = value;
        }
      }
      if (maxCurrencyAmount > 0) {
        return maxCurrencyAmount.toStringAsFixed(maxCurrencyAmount.truncateToDouble() == maxCurrencyAmount ? 0 : 2);
      }
    }

    // 3. Fallback: Find the absolute largest number that looks like a price (has decimals)
    // Receipts often have taxes (НДС) at the very bottom, so we should always pick the largest number.
    final decimalPattern = RegExp(r'\b(\d{1,7}[.,]\d{2})\b');
    final decimalMatches = decimalPattern.allMatches(text);
    double maxAmount = 0.0;
    for (final match in decimalMatches) {
      String raw = match.group(1) ?? '';
      raw = raw.replaceAll(',', '.');
      final value = double.tryParse(raw);
      if (value != null && value > maxAmount) {
        maxAmount = value;
      }
    }

    if (maxAmount > 0) {
      return maxAmount.toStringAsFixed(maxAmount.truncateToDouble() == maxAmount ? 0 : 2);
    }

    return null;
  }

  String? _extractDate(String text) {
    // Match dd.MM.yyyy or dd/MM/yyyy
    final datePattern = RegExp(r'\b(\d{2})[./](\d{2})[./](\d{2,4})\b');
    final matches = datePattern.allMatches(text);
    
    DateTime? mostRecentDate;
    
    for (final match in matches) {
      final dayStr = match.group(1);
      final monthStr = match.group(2);
      var yearStr = match.group(3) ?? '';
      
      if (yearStr.length == 2) {
        yearStr = '20$yearStr';
      }
      
      final day = int.tryParse(dayStr ?? '');
      final month = int.tryParse(monthStr ?? '');
      final year = int.tryParse(yearStr);
      
      if (day != null && month != null && year != null) {
        // Basic validation for reasonable dates (after 2015, not in distant future)
        if (year > 2015 && year <= DateTime.now().year + 1 && month >= 1 && month <= 12 && day >= 1 && day <= 31) {
          try {
            final parsedDate = DateTime(year, month, day);
            if (mostRecentDate == null || parsedDate.isAfter(mostRecentDate)) {
              mostRecentDate = parsedDate;
            }
          } catch (_) {
            // Invalid date like 31.02.2020
          }
        }
      }
    }

    if (mostRecentDate != null) {
      final d = mostRecentDate.day.toString().padLeft(2, '0');
      final m = mostRecentDate.month.toString().padLeft(2, '0');
      final y = mostRecentDate.year;
      return '$d.$m.$y';
    }
    
    return null;
  }

  String? _extractDescription(String text) {
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isNotEmpty) {
      // Return first meaningful line that's not just numbers
      for (final line in lines) {
        final cleaned = line.trim();
        if (cleaned.length > 3 &&
            !RegExp(r'^\d+[.,\s\d]*$').hasMatch(cleaned)) {
          return cleaned.length > 50 ? cleaned.substring(0, 50) : cleaned;
        }
      }
    }
    return null;
  }

  void reset() {
    emit(const OcrState());
  }

  @override
  Future<void> close() {
    _textRecognizer.close();
    return super.close();
  }
}
