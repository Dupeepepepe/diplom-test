import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../logic/analytics/analytics_cubit.dart';
import '../../logic/analytics/analytics_state.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AnalyticsCubit>().analyze();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Аналитика'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AnalyticsCubit>().analyze(),
          ),
        ],
      ),
      body: BlocBuilder<AnalyticsCubit, AnalyticsState>(
        builder: (context, state) {
          if (state.status == AnalyticsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(8),
            children: [
              // Monthly summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Итоги за ${AppFormatters.formatMonthYear(DateTime.now())}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      _StatRow(
                        'Доходы',
                        AppFormatters.formatCurrency(state.totalIncome),
                        AppTheme.incomeColor,
                      ),
                      _StatRow(
                        'Расходы',
                        AppFormatters.formatCurrency(state.totalExpense),
                        AppTheme.expenseColor,
                      ),
                      _StatRow(
                        'Баланс',
                        AppFormatters.formatCurrency(
                            state.totalIncome - state.totalExpense),
                        state.totalIncome >= state.totalExpense
                            ? AppTheme.incomeColor
                            : AppTheme.expenseColor,
                      ),
                      if (state.totalDebt > 0) ...[
                        const Divider(),
                        _StatRow(
                          'Общий долг',
                          AppFormatters.formatCurrency(state.totalDebt),
                          Colors.orange,
                        ),
                        _StatRow(
                          'Платежи/мес',
                          AppFormatters.formatCurrency(
                              state.totalMonthlyPayments),
                          Colors.orange,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // AI Insights header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome,
                        color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Рекомендации',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),

              // Insight cards
              ...state.insights.map((insight) {
                return _InsightCard(
                  title: insight.title,
                  description: insight.description,
                  type: insight.type,
                );
              }),

              if (state.insights.isEmpty && state.status == AnalyticsStatus.loaded)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(Icons.analytics, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Недостаточно данных для анализа',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color, fontSize: 15)),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String title;
  final String description;
  final InsightType type;

  const _InsightCard({
    required this.title,
    required this.description,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, color, bgColor) = switch (type) {
      InsightType.danger => (
          Icons.error,
          AppTheme.dangerColor,
          AppTheme.dangerColor.withValues(alpha: 0.08)
        ),
      InsightType.warning => (
          Icons.warning_amber,
          AppTheme.warningColor,
          AppTheme.warningColor.withValues(alpha: 0.08)
        ),
      InsightType.success => (
          Icons.check_circle,
          AppTheme.successColor,
          AppTheme.successColor.withValues(alpha: 0.08)
        ),
      InsightType.info => (
          Icons.info_outline,
          AppTheme.primaryColor,
          AppTheme.primaryColor.withValues(alpha: 0.08)
        ),
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        color: bgColor,
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
