import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/category_repo.dart';
import '../../data/models/category_model.dart';
import 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _repo = CategoryRepository();

  CategoryCubit() : super(const CategoryState());

  Future<void> loadCategories() async {
    emit(state.copyWith(status: CategoryStatus.loading));
    try {
      final all = await _repo.getAll();
      final income = all.where((c) => c.type == 'income').toList();
      final expense = all.where((c) => c.type == 'expense').toList();

      emit(state.copyWith(
        status: CategoryStatus.loaded,
        categories: all,
        incomeCategories: income,
        expenseCategories: expense,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CategoryStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      await _repo.insert(category);
      await loadCategories();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _repo.update(category);
      await loadCategories();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _repo.delete(id);
      await loadCategories();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
