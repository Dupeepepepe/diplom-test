import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../logic/credit/credit_cubit.dart';
import '../../logic/credit/credit_state.dart';
import '../../logic/settings/settings_cubit.dart';
import 'add_credit_screen.dart';
import 'credit_detail_screen.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Кредиты и рассрочки')),
      body: BlocBuilder<CreditCubit, CreditState>(
        builder: (context, state) {
          if (state.status == CreditStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.credits.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.credit_card_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Нет кредитов',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('Нажмите + чтобы добавить',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(8),
            children: [
              // Summary card
              Card(
                color: AppTheme.primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text('Общий долг',
                          style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 4),
                      BlocBuilder<SettingsCubit, SettingsState>(
                        builder: (context, settingsState) {
                          return Text(
                            AppFormatters.formatCurrency(state.totalDebt),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      BlocBuilder<SettingsCubit, SettingsState>(
                        builder: (context, settingsState) {
                          return Text(
                            'Ежемесячно: ${AppFormatters.formatCurrency(state.totalMonthlyPayments)}',
                            style: const TextStyle(color: Colors.white70),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Credit list
              ...state.credits.map((credit) {
                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CreditDetailScreen(creditId: credit.id),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  credit.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  color: AppTheme.primaryColor, size: 20),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AddCreditScreen(credit: credit),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red, size: 20),
                              onPressed: () =>
                                  _confirmDelete(context, credit.id),
                            ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: credit.progress,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation(
                                AppTheme.primaryColor),
                          ),
                          const SizedBox(height: 8),
                          BlocBuilder<SettingsCubit, SettingsState>(
                            builder: (context, settingsState) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Остаток: ${AppFormatters.formatCurrency(credit.remainingAmount)}',
                                        style: TextStyle(
                                            color: Colors.grey[600], fontSize: 13),
                                      ),
                                      Text(
                                        'из ${AppFormatters.formatCurrency(credit.totalAmount)}',
                                        style: TextStyle(
                                            color: Colors.grey[600], fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Платёж: ${AppFormatters.formatCurrency(credit.monthlyPayment)}/мес',
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 12),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCreditScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить кредит?'),
        content:
            const Text('Это действие нельзя отменить. Все платежи будут удалены.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              context.read<CreditCubit>().deleteCredit(id);
              Navigator.pop(ctx);
            },
            child:
                const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
