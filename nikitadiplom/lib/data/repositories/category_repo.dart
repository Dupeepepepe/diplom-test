import '../database/app_database.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final AppDatabase _db = AppDatabase.instance;

  Future<List<CategoryModel>> getAll() async {
    final db = await _db.database;
    final maps = await db.query('categories', orderBy: 'type, name');
    return maps.map((m) => CategoryModel.fromMap(m)).toList();
  }

  Future<List<CategoryModel>> getByType(String type) async {
    final db = await _db.database;
    final maps = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'name',
    );
    return maps.map((m) => CategoryModel.fromMap(m)).toList();
  }

  Future<CategoryModel?> getById(String id) async {
    final db = await _db.database;
    final maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return CategoryModel.fromMap(maps.first);
  }

  Future<void> insert(CategoryModel category) async {
    final db = await _db.database;
    await db.insert('categories', category.toMap());
  }

  Future<void> update(CategoryModel category) async {
    final db = await _db.database;
    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
