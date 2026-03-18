import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app.dart';
import 'logic/transaction/transaction_cubit.dart';
import 'logic/category/category_cubit.dart';
import 'logic/credit/credit_cubit.dart';
import 'logic/analytics/analytics_cubit.dart';
import 'logic/ocr/ocr_cubit.dart';
import 'logic/settings/settings_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru_RU', null);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsCubit()..loadSettings()),
        BlocProvider(create: (_) => TransactionCubit()..loadTransactions()),
        BlocProvider(create: (_) => CategoryCubit()..loadCategories()),
        BlocProvider(create: (_) => CreditCubit()..loadCredits()),
        BlocProvider(create: (_) => AnalyticsCubit()),
        BlocProvider(create: (_) => OcrCubit()),
      ],
      child: const FinanceApp(),
    ),
  );
}
