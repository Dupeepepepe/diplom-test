import '../database/app_database.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final AppDatabase _db = AppDatabase.instance;

  Future<List<TransactionModel>> getAll() async {
    final db = await _db.database;
    final maps = await db.query('transactions', orderBy: 'date DESC');
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<List<TransactionModel>> getByDateRange(
      DateTime start, DateTime end) async {
    final db = await _db.database;
    final maps = await db.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<List<TransactionModel>> getByCategory(String categoryId) async {
    final db = await _db.database;
    final maps = await db.query(
      'transactions',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'date DESC',
    );
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<List<TransactionModel>> getFiltered({
    DateTime? start,
    DateTime? end,
    String? categoryId,
    String? type,
  }) async {
    final db = await _db.database;
    final conditions = <String>[];
    final args = <dynamic>[];

    if (start != null) {
      conditions.add('date >= ?');
      args.add(start.toIso8601String());
    }
    if (end != null) {
      conditions.add('date <= ?');
      args.add(end.toIso8601String());
    }
    if (categoryId != null) {
      conditions.add('category_id = ?');
      args.add(categoryId);
    }
    if (type != null) {
      conditions.add('type = ?');
      args.add(type);
    }

    final maps = await db.query(
      'transactions',
      where: conditions.isNotEmpty ? conditions.join(' AND ') : null,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'date DESC',
    );
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<void> insert(TransactionModel transaction) async {
    final db = await _db.database;
    await db.insert('transactions', transaction.toMap());
  }

  Future<void> update(TransactionModel transaction) async {
    final db = await _db.database;
    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalByType(String type,
      {DateTime? start, DateTime? end}) async {
    final db = await _db.database;
    final conditions = <String>['type = ?'];
    final args = <dynamic>[type];

    if (start != null) {
      conditions.add('date >= ?');
      args.add(start.toIso8601String());
    }
    if (end != null) {
      conditions.add('date <= ?');
      args.add(end.toIso8601String());
    }

    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM transactions WHERE ${conditions.join(' AND ')}',
      args,
    );
    return (result.first['total'] as num).toDouble();
  }
}
