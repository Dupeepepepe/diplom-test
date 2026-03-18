import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repo.dart';
import '../../core/utils.dart';
import 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final TransactionRepository _repo = TransactionRepository();
  static const _uuid = Uuid();

  TransactionCubit() : super(const TransactionState());

  Future<void> loadTransactions() async {
    emit(state.copyWith(status: TransactionStatus.loading));
    try {
      final now = DateTime.now();
      final start = DateHelper.startOfMonth(now);
      final end = DateHelper.endOfMonth(now);

      final all = await _repo.getAll();
      final income = await _repo.getTotalByType('income', start: start, end: end);
      final expense = await _repo.getTotalByType('expense', start: start, end: end);

      emit(state.copyWith(
        status: TransactionStatus.loaded,
        transactions: all,
        filtered: all,
        totalIncome: income,
        totalExpense: expense,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransactionStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> addTransaction({
    required double amount,
    required String type,
    required String categoryId,
    String? description,
    required DateTime date,
  }) async {
    final transaction = TransactionModel(
      id: _uuid.v4(),
      amount: amount,
      type: type,
      categoryId: categoryId,
      description: description,
      date: date,
      createdAt: DateTime.now(),
    );
    await _repo.insert(transaction);
    await loadTransactions();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _repo.update(transaction);
    await loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await _repo.delete(id);
    await loadTransactions();
  }

  Future<void> applyFilters({
    String? categoryId,
    DateTime? start,
    DateTime? end,
  }) async {
    emit(state.copyWith(status: TransactionStatus.loading));
    try {
      final filtered = await _repo.getFiltered(
        categoryId: categoryId,
        start: start,
        end: end,
      );
      emit(state.copyWith(
        status: TransactionStatus.loaded,
        filtered: filtered,
        selectedCategoryId: categoryId,
        startDate: start,
        endDate: end,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransactionStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> clearFilters() async {
    emit(state.copyWith(
      filtered: state.transactions,
      clearCategoryFilter: true,
      clearDateFilter: true,
    ));
  }
}
