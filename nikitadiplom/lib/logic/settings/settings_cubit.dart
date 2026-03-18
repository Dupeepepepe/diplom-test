import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils.dart';

class SettingsState {
  final String currency;

  const SettingsState({
    required this.currency,
  });

  SettingsState copyWith({
    String? currency,
  }) {
    return SettingsState(
      currency: currency ?? this.currency,
    );
  }
}

class SettingsCubit extends Cubit<SettingsState> {
  static const String _currencyKey = 'selected_currency';

  SettingsCubit() : super(const SettingsState(currency: '₸'));

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final currency = prefs.getString(_currencyKey) ?? '₸';
    AppFormatters.setCurrencySymbol(currency);
    emit(state.copyWith(currency: currency));
  }

  Future<void> setCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency);
    AppFormatters.setCurrencySymbol(currency);
    emit(state.copyWith(currency: currency));
  }
}
