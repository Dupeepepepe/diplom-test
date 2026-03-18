import 'package:equatable/equatable.dart';
import '../../data/models/transaction_model.dart';

enum TransactionStatus { initial, loading, loaded, error }

class TransactionState extends Equatable {
  final TransactionStatus status;
  final List<TransactionModel> transactions;
  final List<TransactionModel> filtered;
  final String? selectedCategoryId;
  final DateTime? startDate;
  final DateTime? endDate;
  final double totalIncome;
  final double totalExpense;
  final String? error;

  const TransactionState({
    this.status = TransactionStatus.initial,
    this.transactions = const [],
    this.filtered = const [],
    this.selectedCategoryId,
    this.startDate,
    this.endDate,
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.error,
  });

  TransactionState copyWith({
    TransactionStatus? status,
    List<TransactionModel>? transactions,
    List<TransactionModel>? filtered,
    String? selectedCategoryId,
    DateTime? startDate,
    DateTime? endDate,
    double? totalIncome,
    double? totalExpense,
    String? error,
    bool clearCategoryFilter = false,
    bool clearDateFilter = false,
  }) {
    return TransactionState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      filtered: filtered ?? this.filtered,
      selectedCategoryId:
          clearCategoryFilter ? null : (selectedCategoryId ?? this.selectedCategoryId),
      startDate: clearDateFilter ? null : (startDate ?? this.startDate),
      endDate: clearDateFilter ? null : (endDate ?? this.endDate),
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        transactions,
        filtered,
        selectedCategoryId,
        startDate,
        endDate,
        totalIncome,
        totalExpense,
        error,
      ];
}
