import 'package:equatable/equatable.dart';
import '../../data/models/category_model.dart';

enum CategoryStatus { initial, loading, loaded, error }

class CategoryState extends Equatable {
  final CategoryStatus status;
  final List<CategoryModel> categories;
  final List<CategoryModel> incomeCategories;
  final List<CategoryModel> expenseCategories;
  final String? error;

  const CategoryState({
    this.status = CategoryStatus.initial,
    this.categories = const [],
    this.incomeCategories = const [],
    this.expenseCategories = const [],
    this.error,
  });

  CategoryState copyWith({
    CategoryStatus? status,
    List<CategoryModel>? categories,
    List<CategoryModel>? incomeCategories,
    List<CategoryModel>? expenseCategories,
    String? error,
  }) {
    return CategoryState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      incomeCategories: incomeCategories ?? this.incomeCategories,
      expenseCategories: expenseCategories ?? this.expenseCategories,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props =>
      [status, categories, incomeCategories, expenseCategories, error];
}
