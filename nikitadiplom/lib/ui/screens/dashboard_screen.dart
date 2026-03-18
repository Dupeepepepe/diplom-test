import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../logic/transaction/transaction_cubit.dart';
import '../../logic/transaction/transaction_state.dart';
import '../../logic/category/category_cubit.dart';
import '../../logic/category/category_state.dart';
import '../widgets/summary_card.dart';
import '../widgets/chart_widget.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';
import 'ocr_screen.dart';
import 'bank_receipt_screen.dart';
import 'manage_categories_screen.dart';
import '../../logic/settings/settings_cubit.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppFormatters.formatMonthYear(DateTime.now())),
            Text(
              'Сегодня: ${AppFormatters.formatDayMonth(DateTime.now())}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'ocr') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const OcrScreen()));
              } else if (value == 'bank') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const BankReceiptScreen()));
              } else if (value == 'categories') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ManageCategoriesScreen()));
              } else if (value == 'currency') {
                _showCurrencyDialog(context);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: 'ocr', child: Text('Сканировать чек')),
              const PopupMenuItem(
                  value: 'bank', child: Text('Загрузить чек банка')),
              const PopupMenuItem(
                  value: 'categories', child: Text('Управление категориями')),
              const PopupMenuItem(
                  value: 'currency', child: Text('Выбрать валюту')),
            ],
          ),
        ],
      ),
      body: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, txState) {
          return BlocBuilder<CategoryCubit, CategoryState>(
            builder: (context, catState) {
              // Build category map
              final catMap = {
                for (final c in catState.categories) c.id: c
              };

              // Build category expenses for chart
              final categoryExpenses = <String, double>{};
              final categoryColors = <String, int>{};
              for (final tx in txState.transactions) {
                if (tx.type == 'expense') {
                  final cat = catMap[tx.categoryId];
                  final name = cat?.name ?? 'Другое';
                  categoryExpenses[name] =
                      (categoryExpenses[name] ?? 0) + tx.amount;
                  if (cat != null) {
                    categoryColors[name] = cat.color;
                  }
                }
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await context.read<TransactionCubit>().loadTransactions();
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
                  children: [
                    // Summary cards
                    Row(
                      children: [
                        SummaryCard(
                          title: 'Доходы',
                          amount: txState.totalIncome,
                          icon: Icons.arrow_downward,
                          color: AppTheme.incomeColor,
                        ),
                        SummaryCard(
                          title: 'Расходы',
                          amount: txState.totalExpense,
                          icon: Icons.arrow_upward,
                          color: AppTheme.expenseColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Balance card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Баланс',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            BlocBuilder<SettingsCubit, SettingsState>(
                              builder: (context, settingsState) {
                                return Text(
                                  AppFormatters.formatCurrency(
                                      txState.totalIncome - txState.totalExpense),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: txState.totalIncome >= txState.totalExpense
                                        ? AppTheme.incomeColor
                                        : AppTheme.expenseColor,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Pie chart
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Расходы по категориям',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ChartWidget(
                              data: categoryExpenses,
                              colors: categoryColors,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Recent transactions
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: Text(
                        'Последние операции',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    if (txState.transactions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.receipt_long,
                                  size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                'Нет операций',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ...txState.transactions.take(5).map((tx) {
                      final cat = catMap[tx.categoryId];
                      return TransactionTile(
                        transaction: tx,
                        category: cat,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddTransactionScreen(transaction: tx),
                            ),
                          );
                        },
                        onDelete: () {
                          context
                              .read<TransactionCubit>()
                              .deleteTransaction(tx.id);
                        },
                      );
                    }),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const AddTransactionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Выберите валюту'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Тенге (₸)'),
                onTap: () {
                  context.read<SettingsCubit>().setCurrency('₸');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: const Text('Доллар (\$)'),
                onTap: () {
                  context.read<SettingsCubit>().setCurrency('\$');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: const Text('Евро (€)'),
                onTap: () {
                  context.read<SettingsCubit>().setCurrency('€');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: const Text('Рубль (₽)'),
                onTap: () {
                  context.read<SettingsCubit>().setCurrency('₽');
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
