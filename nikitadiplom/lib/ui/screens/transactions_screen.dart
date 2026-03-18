import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/transaction/transaction_cubit.dart';
import '../../logic/transaction/transaction_state.dart';
import '../../logic/category/category_cubit.dart';
import '../../logic/category/category_state.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Операции'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, txState) {
          return BlocBuilder<CategoryCubit, CategoryState>(
            builder: (context, catState) {
              final catMap = {
                for (final c in catState.categories) c.id: c
              };

              if (txState.status == TransactionStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              final transactions = txState.filtered;

              if (transactions.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Нет операций',
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                      SizedBox(height: 8),
                      Text('Нажмите + чтобы добавить',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              // Show active filters
              final hasFilters = txState.selectedCategoryId != null ||
                  txState.startDate != null;

              return Column(
                children: [
                  if (hasFilters)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      color: Colors.teal.withValues(alpha: 0.1),
                      child: Row(
                        children: [
                          const Icon(Icons.filter_alt,
                              size: 16, color: Colors.teal),
                          const SizedBox(width: 8),
                          const Text('Фильтры активны',
                              style: TextStyle(color: Colors.teal)),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              context.read<TransactionCubit>().clearFilters();
                            },
                            child: const Text('Сбросить'),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await context
                            .read<TransactionCubit>()
                            .loadTransactions();
                      },
                      child: ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final tx = transactions[index];
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
                        },
                      ),
                    ),
                  ),
                ],
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
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final txCubit = context.read<TransactionCubit>();
    final catState = context.read<CategoryCubit>().state;

    String? selectedCategoryId = txCubit.state.selectedCategoryId;
    DateTime? startDate = txCubit.state.startDate;
    DateTime? endDate = txCubit.state.endDate;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('Фильтры'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Категория',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButton<String?>(
                      value: selectedCategoryId,
                      isExpanded: true,
                      hint: const Text('Все категории'),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Все категории'),
                        ),
                        ...catState.categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat.id,
                            child: Text(cat.name),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() => selectedCategoryId = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Период',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: ctx,
                                initialDate: startDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() => startDate = date);
                              }
                            },
                            child: Text(startDate != null
                                ? '${startDate!.day}.${startDate!.month}.${startDate!.year}'
                                : 'С'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: ctx,
                                initialDate: endDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now().add(
                                    const Duration(days: 1)),
                              );
                              if (date != null) {
                                setState(() => endDate = date);
                              }
                            },
                            child: Text(endDate != null
                                ? '${endDate!.day}.${endDate!.month}.${endDate!.year}'
                                : 'По'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    txCubit.clearFilters();
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Сбросить'),
                ),
                ElevatedButton(
                  onPressed: () {
                    txCubit.applyFilters(
                      categoryId: selectedCategoryId,
                      start: startDate,
                      end: endDate,
                    );
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Применить'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
