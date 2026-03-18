class CreditModel {
  final String id;
  final String name;
  final double totalAmount;
  final int termMonths;
  final double monthlyPayment;
  final double interestRate;
  final DateTime startDate;
  final double remainingAmount;

  const CreditModel({
    required this.id,
    required this.name,
    required this.totalAmount,
    required this.termMonths,
    required this.monthlyPayment,
    this.interestRate = 0,
    required this.startDate,
    required this.remainingAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'total_amount': totalAmount,
      'term_months': termMonths,
      'monthly_payment': monthlyPayment,
      'interest_rate': interestRate,
      'start_date': startDate.toIso8601String(),
      'remaining_amount': remainingAmount,
    };
  }

  factory CreditModel.fromMap(Map<String, dynamic> map) {
    return CreditModel(
      id: map['id'] as String,
      name: map['name'] as String,
      totalAmount: (map['total_amount'] as num).toDouble(),
      termMonths: map['term_months'] as int,
      monthlyPayment: (map['monthly_payment'] as num).toDouble(),
      interestRate: (map['interest_rate'] as num).toDouble(),
      startDate: DateTime.parse(map['start_date'] as String),
      remainingAmount: (map['remaining_amount'] as num).toDouble(),
    );
  }

  CreditModel copyWith({
    String? id,
    String? name,
    double? totalAmount,
    int? termMonths,
    double? monthlyPayment,
    double? interestRate,
    DateTime? startDate,
    double? remainingAmount,
  }) {
    return CreditModel(
      id: id ?? this.id,
      name: name ?? this.name,
      totalAmount: totalAmount ?? this.totalAmount,
      termMonths: termMonths ?? this.termMonths,
      monthlyPayment: monthlyPayment ?? this.monthlyPayment,
      interestRate: interestRate ?? this.interestRate,
      startDate: startDate ?? this.startDate,
      remainingAmount: remainingAmount ?? this.remainingAmount,
    );
  }

  double get progress =>
      totalAmount > 0 ? (totalAmount - remainingAmount) / totalAmount : 0;

  int get paidMonths =>
      monthlyPayment > 0
          ? ((totalAmount - remainingAmount) / monthlyPayment).floor()
          : 0;
}
