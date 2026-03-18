import 'package:equatable/equatable.dart';
import '../../data/models/credit_model.dart';
import '../../data/models/credit_payment_model.dart';

enum CreditStatus { initial, loading, loaded, error }

class CreditState extends Equatable {
  final CreditStatus status;
  final List<CreditModel> credits;
  final List<CreditPaymentModel> payments;
  final double totalDebt;
  final double totalMonthlyPayments;
  final String? error;

  const CreditState({
    this.status = CreditStatus.initial,
    this.credits = const [],
    this.payments = const [],
    this.totalDebt = 0,
    this.totalMonthlyPayments = 0,
    this.error,
  });

  CreditState copyWith({
    CreditStatus? status,
    List<CreditModel>? credits,
    List<CreditPaymentModel>? payments,
    double? totalDebt,
    double? totalMonthlyPayments,
    String? error,
  }) {
    return CreditState(
      status: status ?? this.status,
      credits: credits ?? this.credits,
      payments: payments ?? this.payments,
      totalDebt: totalDebt ?? this.totalDebt,
      totalMonthlyPayments: totalMonthlyPayments ?? this.totalMonthlyPayments,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props =>
      [status, credits, payments, totalDebt, totalMonthlyPayments, error];
}
