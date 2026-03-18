import 'package:equatable/equatable.dart';

class AnalyticsInsight {
  final String title;
  final String description;
  final InsightType type;
  final double? value;

  const AnalyticsInsight({
    required this.title,
    required this.description,
    required this.type,
    this.value,
  });
}

enum InsightType { warning, danger, success, info }

enum AnalyticsStatus { initial, loading, loaded, error }

class AnalyticsState extends Equatable {
  final AnalyticsStatus status;
  final List<AnalyticsInsight> insights;
  final double totalIncome;
  final double totalExpense;
  final double totalDebt;
  final double totalMonthlyPayments;
  final Map<String, double> categoryExpenses;
  final String? error;

  const AnalyticsState({
    this.status = AnalyticsStatus.initial,
    this.insights = const [],
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.totalDebt = 0,
    this.totalMonthlyPayments = 0,
    this.categoryExpenses = const {},
    this.error,
  });

  AnalyticsState copyWith({
    AnalyticsStatus? status,
    List<AnalyticsInsight>? insights,
    double? totalIncome,
    double? totalExpense,
    double? totalDebt,
    double? totalMonthlyPayments,
    Map<String, double>? categoryExpenses,
    String? error,
  }) {
    return AnalyticsState(
      status: status ?? this.status,
      insights: insights ?? this.insights,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      totalDebt: totalDebt ?? this.totalDebt,
      totalMonthlyPayments: totalMonthlyPayments ?? this.totalMonthlyPayments,
      categoryExpenses: categoryExpenses ?? this.categoryExpenses,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        insights,
        totalIncome,
        totalExpense,
        totalDebt,
        totalMonthlyPayments,
        categoryExpenses,
        error,
      ];
}
