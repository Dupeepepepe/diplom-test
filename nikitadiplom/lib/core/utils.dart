import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IconHelper {
  IconHelper._();

  static IconData getIconFromCodePoint(int codePoint) {
    return getAvailableIcons().firstWhere(
      (icon) => icon.codePoint == codePoint,
      orElse: () => Icons.category,
    );
  }

  static List<IconData> getAvailableIcons() {
    return [
      Icons.category,
      Icons.shopping_cart,
      Icons.restaurant,
      Icons.directions_car,
      Icons.home,
      Icons.work,
      Icons.phone,
      Icons.medical_services,
      Icons.school,
      Icons.flight,
      Icons.payments,
      Icons.account_balance,
      Icons.fitness_center,
      Icons.movie,
      Icons.checkroom,
      Icons.pets,
      Icons.local_cafe,
      Icons.fastfood,
      Icons.electric_car,
      Icons.pedal_bike,
      Icons.train,
      Icons.local_gas_station,
      Icons.computer,
      Icons.sports_esports,
      Icons.stadium,
      Icons.child_care,
      Icons.face,
      Icons.spa,
      Icons.palette,
      Icons.music_note,
      Icons.receipt,
      Icons.health_and_safety,
      Icons.local_pharmacy,
      Icons.chair,
      Icons.bed,
      // More icons added below:
      Icons.shopping_bag,
      Icons.store,
      Icons.card_giftcard,
      Icons.cake,
      Icons.icecream,
      Icons.liquor,
      Icons.local_pizza,
      Icons.local_bar,
      Icons.smoking_rooms,
      Icons.casino,
      Icons.sports_soccer,
      Icons.sports_basketball,
      Icons.sports_tennis,
      Icons.sports_motorsports,
      Icons.directions_bus,
      Icons.directions_subway,
      Icons.directions_boat,
      Icons.two_wheeler,
      Icons.local_taxi,
      Icons.local_shipping,
      Icons.build,
      Icons.engineering,
      Icons.construction,
      Icons.hardware,
      Icons.plumbing,
      Icons.carpenter,
      Icons.science,
      Icons.biotech,
      Icons.memory,
      Icons.headset,
      Icons.camera_alt,
      Icons.photo_library,
      Icons.tv,
      Icons.book,
      Icons.menu_book,
      Icons.library_books,
      Icons.design_services,
      Icons.brush,
      Icons.theater_comedy,
      Icons.festival,
      Icons.beach_access,
      Icons.pool,
      Icons.hotel,
      Icons.luggage,
      Icons.self_improvement,
      Icons.favorite,
      Icons.volunteer_activism,
      Icons.diversity_3,
      Icons.family_restroom,
      Icons.savings,
      Icons.price_change,
      Icons.currency_exchange,
      Icons.account_balance_wallet,
      Icons.monitor_weight,
    ];
  }
}

class AppFormatters {
  AppFormatters._();

  static NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'ru_RU', symbol: '₸', decimalDigits: 0);

  static final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy', 'ru_RU');
  static final DateFormat _dayMonthFormat = DateFormat('d MMMM', 'ru_RU');

  static void setCurrencySymbol(String symbol) {
    _currencyFormat = NumberFormat.currency(locale: 'ru_RU', symbol: symbol, decimalDigits: 0);
  }

  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  static String formatDayMonth(DateTime date) {
    return _dayMonthFormat.format(date);
  }

  static String formatCompactNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    }
    return number.toStringAsFixed(0);
  }
}

class DateHelper {
  DateHelper._();

  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Сегодня';
    if (diff == 1) return 'Вчера';
    if (diff == 2) return 'Позавчера';
    return AppFormatters.formatDate(date);
  }
}
