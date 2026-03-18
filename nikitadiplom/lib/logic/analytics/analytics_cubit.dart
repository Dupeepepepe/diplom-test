import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/transaction_repo.dart';
import '../../data/repositories/category_repo.dart';
import '../../data/repositories/credit_repo.dart';
import '../../core/utils.dart';
import 'analytics_state.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  final TransactionRepository _transRepo = TransactionRepository();
  final CategoryRepository _catRepo = CategoryRepository();
  final CreditRepository _creditRepo = CreditRepository();

  AnalyticsCubit() : super(const AnalyticsState());

  Future<void> analyze() async {
    emit(state.copyWith(status: AnalyticsStatus.loading));
    try {
      final now = DateTime.now();
      final start = DateHelper.startOfMonth(now);
      final end = DateHelper.endOfMonth(now);

      final income =
          await _transRepo.getTotalByType('income', start: start, end: end);
      final expense =
          await _transRepo.getTotalByType('expense', start: start, end: end);
      final totalDebt = await _creditRepo.getTotalDebt();
      final monthlyPayments = await _creditRepo.getTotalMonthlyPayments();

      // Calculate category expenses
      final categories = await _catRepo.getByType('expense');
      final transactions =
          await _transRepo.getFiltered(start: start, end: end, type: 'expense');
      final categoryExpenses = <String, double>{};
      for (final cat in categories) {
        final catTotal = transactions
            .where((t) => t.categoryId == cat.id)
            .fold<double>(0, (sum, t) => sum + t.amount);
        if (catTotal > 0) {
          categoryExpenses[cat.name] = catTotal;
        }
      }

      // Generate insights
      final insights = _generateInsights(
        income: income,
        expense: expense,
        totalDebt: totalDebt,
        monthlyPayments: monthlyPayments,
        categoryExpenses: categoryExpenses,
        categories: categories,
      );

      emit(state.copyWith(
        status: AnalyticsStatus.loaded,
        insights: insights,
        totalIncome: income,
        totalExpense: expense,
        totalDebt: totalDebt,
        totalMonthlyPayments: monthlyPayments,
        categoryExpenses: categoryExpenses,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AnalyticsStatus.error,
        error: e.toString(),
      ));
    }
  }

  List<AnalyticsInsight> _generateInsights({
    required double income,
    required double expense,
    required double totalDebt,
    required double monthlyPayments,
    required Map<String, double> categoryExpenses,
    required List<CategoryModel> categories,
  }) {
    final insights = <AnalyticsInsight>[];

    // Rule 1: Expenses exceed income
    if (income > 0 && expense > income) {
      insights.add(AnalyticsInsight(
        title: 'Расходы превышают доходы',
        description:
            'В этом месяце ваши расходы (${AppFormatters.formatCurrency(expense)}) '
            'превысили доходы (${AppFormatters.formatCurrency(income)}). '
            'Рекомендуем пересмотреть бюджет.',
        type: InsightType.danger,
        value: expense - income,
      ));
    }

    // Rule 2: Credit load > 40%
    if (income > 0 && monthlyPayments > 0) {
      final creditRatio = monthlyPayments / income;
      if (creditRatio > 0.4) {
        insights.add(AnalyticsInsight(
          title: 'Высокая кредитная нагрузка',
          description:
              '${(creditRatio * 100).toStringAsFixed(0)}% вашего дохода уходит на кредиты. '
              'Рекомендуемый показатель — не более 40%.',
          type: InsightType.danger,
          value: creditRatio,
        ));
      } else if (creditRatio > 0.25) {
        insights.add(AnalyticsInsight(
          title: 'Кредитная нагрузка в норме',
          description:
              '${(creditRatio * 100).toStringAsFixed(0)}% дохода направлено на кредиты. '
              'Это в пределах нормы, но следите за динамикой.',
          type: InsightType.warning,
          value: creditRatio,
        ));
      }
    }

    // Rule 3: Category concentration > 50%
    if (expense > 0 && categoryExpenses.isNotEmpty) {
      for (final entry in categoryExpenses.entries) {
        final ratio = entry.value / expense;
        if (ratio > 0.5) {
          insights.add(AnalyticsInsight(
            title: 'Концентрация расходов: ${entry.key}',
            description:
                '${(ratio * 100).toStringAsFixed(0)}% всех расходов приходится на категорию "${entry.key}". '
                'Попробуйте диверсифицировать траты.',
            type: InsightType.warning,
            value: ratio,
          ));
        }
      }
    }

    // Rule 4: Savings rate
    if (income > 0) {
      final savings = income - expense;
      final savingsRate = savings / income;
      if (savingsRate >= 0.2) {
        insights.add(AnalyticsInsight(
          title: 'Хороший уровень сбережений',
          description:
              'Вы сберегаете ${(savingsRate * 100).toStringAsFixed(0)}% дохода. Отличный результат!',
          type: InsightType.success,
          value: savingsRate,
        ));
      } else if (savingsRate >= 0 && savingsRate < 0.1) {
        insights.add(AnalyticsInsight(
          title: 'Низкий уровень сбережений',
          description:
              'Вы сберегаете всего ${(savingsRate * 100).toStringAsFixed(0)}% дохода. '
              'Рекомендуется откладывать не менее 20%.',
          type: InsightType.warning,
          value: savingsRate,
        ));
      }
    }

    // Rule 5: Total debt overview
    if (totalDebt > 0) {
      insights.add(AnalyticsInsight(
        title: 'Общий долг',
        description:
            'Ваш общий долг составляет ${AppFormatters.formatCurrency(totalDebt)}. '
            'Ежемесячный платёж: ${AppFormatters.formatCurrency(monthlyPayments)}.',
        type: InsightType.info,
        value: totalDebt,
      ));
    }

    // No data insight
    if (income == 0 && expense == 0) {
      insights.add(const AnalyticsInsight(
        title: 'Нет данных для анализа',
        description:
            'Добавьте доходы и расходы за текущий месяц, чтобы получить аналитику.',
        type: InsightType.info,
      ));
    }

    return insights;
  }
}
