import 'package:equatable/equatable.dart';

enum OcrStatus { initial, picking, processing, extracted, error }

class OcrState extends Equatable {
  final OcrStatus status;
  final String? imagePath;
  final String? extractedAmount;
  final String? extractedDate;
  final String? extractedDescription;
  final String? fullText;
  final String? error;

  const OcrState({
    this.status = OcrStatus.initial,
    this.imagePath,
    this.extractedAmount,
    this.extractedDate,
    this.extractedDescription,
    this.fullText,
    this.error,
  });

  OcrState copyWith({
    OcrStatus? status,
    String? imagePath,
    String? extractedAmount,
    String? extractedDate,
    String? extractedDescription,
    String? fullText,
    String? error,
  }) {
    return OcrState(
      status: status ?? this.status,
      imagePath: imagePath ?? this.imagePath,
      extractedAmount: extractedAmount ?? this.extractedAmount,
      extractedDate: extractedDate ?? this.extractedDate,
      extractedDescription: extractedDescription ?? this.extractedDescription,
      fullText: fullText ?? this.fullText,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        imagePath,
        extractedAmount,
        extractedDate,
        extractedDescription,
        fullText,
        error,
      ];
}
