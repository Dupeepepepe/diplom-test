import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme.dart';
import '../../data/models/credit_model.dart';
import '../../logic/credit/credit_cubit.dart';
import '../../logic/settings/settings_cubit.dart';

class AddCreditScreen extends StatefulWidget {
  final CreditModel? credit;

  const AddCreditScreen({super.key, this.credit});

  @override
  State<AddCreditScreen> createState() => _AddCreditScreenState();
}

class _AddCreditScreenState extends State<AddCreditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _termController = TextEditingController();
  final _paymentController = TextEditingController();
  final _rateController = TextEditingController(text: '0');
  DateTime _startDate = DateTime.now();

  bool get _isEditing => widget.credit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final c = widget.credit!;
      _nameController.text = c.name;
      _amountController.text = c.totalAmount.toStringAsFixed(0);
      _termController.text = c.termMonths.toString();
      _paymentController.text = c.monthlyPayment.toStringAsFixed(0);
      _rateController.text = c.interestRate.toString();
      _startDate = c.startDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _termController.dispose();
    _paymentController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Редактирование кредита' : 'Новый кредит'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Название',
                prefixIcon: Icon(Icons.label),
                hintText: 'Например: Ипотека',
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Введите название' : null,
            ),
            const SizedBox(height: 16),
            BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, settingsState) {
                return TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Общая сумма',
                    suffixText: settingsState.currency,
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Введите сумму';
                    if (double.tryParse(v) == null) return 'Некорректная сумма';
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _termController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Срок (месяцев)',
                prefixIcon: Icon(Icons.calendar_month),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Введите срок';
                if (int.tryParse(v) == null) return 'Некорректный срок';
                return null;
              },
            ),
            const SizedBox(height: 16),
            BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, settingsState) {
                return TextFormField(
                  controller: _paymentController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Ежемесячный платёж',
                    suffixText: settingsState.currency,
                    prefixIcon: const Icon(Icons.payments),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Введите платёж';
                    if (double.tryParse(v) == null) return 'Некорректный платёж';
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _rateController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Ставка % (необязательно)',
                suffixText: '%',
                prefixIcon: Icon(Icons.percent),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
              title: Text(
                  '${_startDate.day}.${_startDate.month.toString().padLeft(2, '0')}.${_startDate.year}'),
              subtitle: const Text('Дата начала'),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (d != null) setState(() => _startDate = d);
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(
                  _isEditing ? 'Сохранить' : 'Добавить кредит',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final totalAmount = double.parse(_amountController.text);

    if (_isEditing) {
      final original = widget.credit!;
      // If totalAmount changed, recalculate remaining proportionally
      final remainingAmount = totalAmount != original.totalAmount
          ? totalAmount - (original.totalAmount - original.remainingAmount)
          : original.remainingAmount;

      context.read<CreditCubit>().updateCredit(
            id: original.id,
            name: _nameController.text.trim(),
            totalAmount: totalAmount,
            termMonths: int.parse(_termController.text),
            monthlyPayment: double.parse(_paymentController.text),
            interestRate: double.tryParse(_rateController.text) ?? 0,
            startDate: _startDate,
            remainingAmount: remainingAmount < 0 ? 0 : remainingAmount,
          );
    } else {
      context.read<CreditCubit>().addCredit(
            name: _nameController.text.trim(),
            totalAmount: totalAmount,
            termMonths: int.parse(_termController.text),
            monthlyPayment: double.parse(_paymentController.text),
            interestRate: double.tryParse(_rateController.text) ?? 0,
            startDate: _startDate,
          );
    }

    Navigator.pop(context);
  }
}
