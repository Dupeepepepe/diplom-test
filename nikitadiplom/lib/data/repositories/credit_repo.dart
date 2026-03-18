import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../models/credit_model.dart';
import '../models/credit_payment_model.dart';

class CreditRepository {
  final AppDatabase _db = AppDatabase.instance;
  static const _uuid = Uuid();

  Future<List<CreditModel>> getAll() async {
    final db = await _db.database;
    final maps = await db.query('credits', orderBy: 'start_date DESC');
    return maps.map((m) => CreditModel.fromMap(m)).toList();
  }

  Future<CreditModel?> getById(String id) async {
    final db = await _db.database;
    final maps = await db.query(
      'credits',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return CreditModel.fromMap(maps.first);
  }

  Future<void> insert(CreditModel credit) async {
    final db = await _db.database;
    await db.insert('credits', credit.toMap());
    await _generatePayments(credit);
  }

  Future<void> update(CreditModel credit) async {
    final db = await _db.database;
    await db.update(
      'credits',
      credit.toMap(),
      where: 'id = ?',
      whereArgs: [credit.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete('credit_payments',
        where: 'credit_id = ?', whereArgs: [id]);
    await db.delete('credits', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateWithPayments(CreditModel credit) async {
    final db = await _db.database;
    await db.update(
      'credits',
      credit.toMap(),
      where: 'id = ?',
      whereArgs: [credit.id],
    );
    // Remove unpaid payments and regenerate
    await db.delete(
      'credit_payments',
      where: 'credit_id = ? AND is_paid = 0',
      whereArgs: [credit.id],
    );
    // Count already paid payments
    final paidResult = await db.query(
      'credit_payments',
      where: 'credit_id = ? AND is_paid = 1',
      whereArgs: [credit.id],
    );
    final paidCount = paidResult.length;
    final remainingMonths = credit.termMonths - paidCount;
    if (remainingMonths > 0) {
      for (int i = 0; i < remainingMonths; i++) {
        final dueDate = DateTime(
          credit.startDate.year,
          credit.startDate.month + paidCount + i + 1,
          credit.startDate.day,
        );
        final payment = CreditPaymentModel(
          id: _uuid.v4(),
          creditId: credit.id,
          amount: credit.monthlyPayment,
          dueDate: dueDate,
        );
        await db.insert('credit_payments', payment.toMap());
      }
    }
  }

  Future<List<CreditPaymentModel>> getPayments(String creditId) async {
    final db = await _db.database;
    final maps = await db.query(
      'credit_payments',
      where: 'credit_id = ?',
      whereArgs: [creditId],
      orderBy: 'due_date ASC',
    );
    return maps.map((m) => CreditPaymentModel.fromMap(m)).toList();
  }

  Future<void> markPaymentPaid(String paymentId, String creditId) async {
    final db = await _db.database;
    await db.update(
      'credit_payments',
      {'is_paid': 1},
      where: 'id = ?',
      whereArgs: [paymentId],
    );

    // Update remaining amount
    final credit = await getById(creditId);
    if (credit != null) {
      final payments = await getPayments(creditId);
      final paidSum = payments
          .where((p) => p.isPaid)
          .fold<double>(0, (sum, p) => sum + p.amount);
      final remaining = credit.totalAmount - paidSum;
      await update(credit.copyWith(
        remainingAmount: remaining < 0 ? 0 : remaining,
      ));
    }
  }

  Future<void> _generatePayments(CreditModel credit) async {
    final db = await _db.database;
    for (int i = 0; i < credit.termMonths; i++) {
      final dueDate = DateTime(
        credit.startDate.year,
        credit.startDate.month + i + 1,
        credit.startDate.day,
      );
      final payment = CreditPaymentModel(
        id: _uuid.v4(),
        creditId: credit.id,
        amount: credit.monthlyPayment,
        dueDate: dueDate,
      );
      await db.insert('credit_payments', payment.toMap());
    }
  }

  Future<List<CreditPaymentModel>> getUpcomingPayments() async {
    final db = await _db.database;
    final now = DateTime.now().toIso8601String();
    final maps = await db.query(
      'credit_payments',
      where: 'is_paid = 0 AND due_date >= ?',
      whereArgs: [now],
      orderBy: 'due_date ASC',
      limit: 10,
    );
    return maps.map((m) => CreditPaymentModel.fromMap(m)).toList();
  }

  Future<double> getTotalDebt() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(remaining_amount), 0) as total FROM credits',
    );
    return (result.first['total'] as num).toDouble();
  }

  Future<double> getTotalMonthlyPayments() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(monthly_payment), 0) as total FROM credits',
    );
    return (result.first['total'] as num).toDouble();
  }
}
