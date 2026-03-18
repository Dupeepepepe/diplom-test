class CreditPaymentModel {
  final String id;
  final String creditId;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;

  const CreditPaymentModel({
    required this.id,
    required this.creditId,
    required this.amount,
    required this.dueDate,
    this.isPaid = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'credit_id': creditId,
      'amount': amount,
      'due_date': dueDate.toIso8601String(),
      'is_paid': isPaid ? 1 : 0,
    };
  }

  factory CreditPaymentModel.fromMap(Map<String, dynamic> map) {
    return CreditPaymentModel(
      id: map['id'] as String,
      creditId: map['credit_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      dueDate: DateTime.parse(map['due_date'] as String),
      isPaid: (map['is_paid'] as int) == 1,
    );
  }

  CreditPaymentModel copyWith({
    String? id,
    String? creditId,
    double? amount,
    DateTime? dueDate,
    bool? isPaid,
  }) {
    return CreditPaymentModel(
      id: id ?? this.id,
      creditId: creditId ?? this.creditId,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}
