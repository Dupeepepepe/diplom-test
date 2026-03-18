import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../logic/credit/credit_cubit.dart';
import '../../logic/credit/credit_state.dart';
import '../../logic/settings/settings_cubit.dart';

class CreditDetailScreen extends StatefulWidget {
  final String creditId;

  const CreditDetailScreen({super.key, required this.creditId});

  @override
  State<CreditDetailScreen> createState() => _CreditDetailScreenState();
}

class _CreditDetailScreenState extends State<CreditDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CreditCubit>().loadPayments(widget.creditId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('График платежей')),
      body: BlocBuilder<CreditCubit, CreditState>(
        builder: (context, state) {
          final credit =
              state.credits.where((c) => c.id == widget.creditId).firstOrNull;
          if (credit == null) {
            return const Center(child: Text('Кредит не найден'));
          }

          final payments = state.payments;
          final nextPayment =
              payments.where((p) => !p.isPaid).firstOrNull;

          return ListView(
            padding: const EdgeInsets.all(8),
            children: [
              // Credit info card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        credit.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      BlocBuilder<SettingsCubit, SettingsState>(
                        builder: (context, settingsState) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _InfoRow('Общая сумма',
                                  AppFormatters.formatCurrency(credit.totalAmount)),
                              _InfoRow('Остаток',
                                  AppFormatters.formatCurrency(credit.remainingAmount)),
                              _InfoRow('Ежемесячный платёж',
                                  AppFormatters.formatCurrency(credit.monthlyPayment)),
                            ],
                          );
                        },
                      ),
                      _InfoRow('Срок', '${credit.termMonths} мес.'),
                      if (credit.interestRate > 0)
                        _InfoRow('Ставка', '${credit.interestRate}%'),
                      _InfoRow('Дата начала',
                          AppFormatters.formatDate(credit.startDate)),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: credit.progress,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation(
                            AppTheme.primaryColor),
                        minHeight: 8,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(credit.progress * 100).toStringAsFixed(0)}% выплачено',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),

              // Next payment
              if (nextPayment != null)
                Card(
                  color: AppTheme.warningColor.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_active,
                            color: AppTheme.warningColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Ближайший платёж',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              BlocBuilder<SettingsCubit, SettingsState>(
                                builder: (context, settingsState) {
                                  return Text(
                                    '${AppFormatters.formatCurrency(nextPayment.amount)} — ${AppFormatters.formatDate(nextPayment.dueDate)}',
                                    style: TextStyle(color: Colors.grey[700]),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 8),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Все платежи',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),

              // Payment schedule
              ...payments.map((payment) {
                final isPast = payment.dueDate.isBefore(DateTime.now());
                return Card(
                  child: ListTile(
                    leading: Icon(
                      payment.isPaid
                          ? Icons.check_circle
                          : isPast
                              ? Icons.warning
                              : Icons.schedule,
                      color: payment.isPaid
                          ? AppTheme.successColor
                          : isPast
                              ? AppTheme.dangerColor
                              : Colors.grey,
                    ),
                    title: BlocBuilder<SettingsCubit, SettingsState>(
                      builder: (context, settingsState) {
                        return Text(AppFormatters.formatCurrency(payment.amount));
                      },
                    ),
                    subtitle:
                        Text(AppFormatters.formatDate(payment.dueDate)),
                    trailing: payment.isPaid
                        ? const Chip(
                            label: Text('Оплачено',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.white)),
                            backgroundColor: AppTheme.successColor,
                            padding: EdgeInsets.zero,
                          )
                        : TextButton(
                            onPressed: () {
                              context
                                  .read<CreditCubit>()
                                  .markPaymentPaid(
                                      payment.id, widget.creditId);
                            },
                            child: const Text('Оплатить'),
                          ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
