import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'tables.dart';
import '../../core/constants.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'finance.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(Tables.categories);
    await db.execute(Tables.transactions);
    await db.execute(Tables.credits);
    await db.execute(Tables.creditPayments);

    await _seedCategories(db);
  }

  Future<void> _seedCategories(Database db) async {
    const uuid = Uuid();

    for (final cat in DefaultCategories.expense) {
      await db.insert('categories', {
        'id': uuid.v4(),
        'name': cat['name'],
        'icon': cat['icon'],
        'color': cat['color'],
        'type': cat['type'],
      });
    }

    for (final cat in DefaultCategories.income) {
      await db.insert('categories', {
        'id': uuid.v4(),
        'name': cat['name'],
        'icon': cat['icon'],
        'color': cat['color'],
        'type': cat['type'],
      });
    }
  }
}
