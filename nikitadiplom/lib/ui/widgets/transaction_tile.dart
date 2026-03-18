import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/category_model.dart';
import '../../logic/settings/settings_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final CategoryModel? category;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.category,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    final color = isIncome ? AppTheme.incomeColor : AppTheme.expenseColor;
    final sign = isIncome ? '+' : '-';

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor:
              category != null ? Color(category!.color).withValues(alpha: 0.15) : Colors.grey[200],
          child: Icon(
            category != null
                ? IconHelper.getIconFromCodePoint(category!.icon)
                : Icons.category,
            color: category != null ? Color(category!.color) : Colors.grey,
            size: 20,
          ),
        ),
        title: Text(
          transaction.description ?? category?.name ?? 'Без описания',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          DateHelper.relativeDate(transaction.date),
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, settingsState) {
                return Text(
                  '$sign${AppFormatters.formatCurrency(transaction.amount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 15,
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Удалить операцию?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Отмена'),
                      ),
                      TextButton(
                        onPressed: () {
                          onDelete?.call();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Удалить',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
