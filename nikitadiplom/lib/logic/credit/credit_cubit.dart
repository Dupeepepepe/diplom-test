import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/credit_model.dart';
import '../../data/repositories/credit_repo.dart';
import 'credit_state.dart';

class CreditCubit extends Cubit<CreditState> {
  final CreditRepository _repo = CreditRepository();
  static const _uuid = Uuid();

  CreditCubit() : super(const CreditState());

  Future<void> loadCredits() async {
    emit(state.copyWith(status: CreditStatus.loading));
    try {
      final credits = await _repo.getAll();
      final totalDebt = await _repo.getTotalDebt();
      final totalMonthly = await _repo.getTotalMonthlyPayments();

      emit(state.copyWith(
        status: CreditStatus.loaded,
        credits: credits,
        totalDebt: totalDebt,
        totalMonthlyPayments: totalMonthly,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CreditStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> addCredit({
    required String name,
    required double totalAmount,
    required int termMonths,
    required double monthlyPayment,
    double interestRate = 0,
    required DateTime startDate,
  }) async {
    final credit = CreditModel(
      id: _uuid.v4(),
      name: name,
      totalAmount: totalAmount,
      termMonths: termMonths,
      monthlyPayment: monthlyPayment,
      interestRate: interestRate,
      startDate: startDate,
      remainingAmount: totalAmount,
    );
    await _repo.insert(credit);
    await loadCredits();
  }

  Future<void> updateCredit({
    required String id,
    required String name,
    required double totalAmount,
    required int termMonths,
    required double monthlyPayment,
    double interestRate = 0,
    required DateTime startDate,
    required double remainingAmount,
  }) async {
    final credit = CreditModel(
      id: id,
      name: name,
      totalAmount: totalAmount,
      termMonths: termMonths,
      monthlyPayment: monthlyPayment,
      interestRate: interestRate,
      startDate: startDate,
      remainingAmount: remainingAmount,
    );
    await _repo.updateWithPayments(credit);
    await loadCredits();
  }

  Future<void> deleteCredit(String id) async {
    await _repo.delete(id);
    await loadCredits();
  }

  Future<void> loadPayments(String creditId) async {
    try {
      final payments = await _repo.getPayments(creditId);
      emit(state.copyWith(payments: payments));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> markPaymentPaid(String paymentId, String creditId) async {
    await _repo.markPaymentPaid(paymentId, creditId);
    await loadPayments(creditId);
    await loadCredits();
  }
}
