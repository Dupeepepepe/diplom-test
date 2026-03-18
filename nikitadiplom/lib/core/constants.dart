class DefaultCategories {
  DefaultCategories._();

  static const List<Map<String, dynamic>> expense = [
    {
      'name': 'Еда',
      'icon': 0xe25a, // Icons.restaurant
      'color': 0xFFFF7043,
      'type': 'expense',
    },
    {
      'name': 'Транспорт',
      'icon': 0xe1d5, // Icons.directions_car
      'color': 0xFF42A5F5,
      'type': 'expense',
    },
    {
      'name': 'Развлечения',
      'icon': 0xe40f, // Icons.movie
      'color': 0xFFAB47BC,
      'type': 'expense',
    },
    {
      'name': 'Покупки',
      'icon': 0xe59c, // Icons.shopping_bag
      'color': 0xFFEC407A,
      'type': 'expense',
    },
    {
      'name': 'Здоровье',
      'icon': 0xe3e2, // Icons.local_hospital
      'color': 0xFF26A69A,
      'type': 'expense',
    },
    {
      'name': 'Образование',
      'icon': 0xe559, // Icons.school
      'color': 0xFF5C6BC0,
      'type': 'expense',
    },
    {
      'name': 'ЖКХ',
      'icon': 0xe318, // Icons.home
      'color': 0xFF8D6E63,
      'type': 'expense',
    },
    {
      'name': 'Связь',
      'icon': 0xe4a2, // Icons.phone_android
      'color': 0xFF78909C,
      'type': 'expense',
    },
    {
      'name': 'Другое',
      'icon': 0xe3e0, // Icons.more_horiz
      'color': 0xFF90A4AE,
      'type': 'expense',
    },
  ];

  static const List<Map<String, dynamic>> income = [
    {
      'name': 'Зарплата',
      'icon': 0xe850, // Icons.account_balance_wallet
      'color': 0xFF66BB6A,
      'type': 'income',
    },
    {
      'name': 'Подработка',
      'icon': 0xe943, // Icons.work
      'color': 0xFF29B6F6,
      'type': 'income',
    },
    {
      'name': 'Инвестиции',
      'icon': 0xe906, // Icons.trending_up
      'color': 0xFFFFA726,
      'type': 'income',
    },
    {
      'name': 'Подарок',
      'icon': 0xe8f6, // Icons.card_giftcard
      'color': 0xFFEF5350,
      'type': 'income',
    },
    {
      'name': 'Другое',
      'icon': 0xe3e0, // Icons.more_horiz
      'color': 0xFF90A4AE,
      'type': 'income',
    },
  ];
}

class AppStrings {
  AppStrings._();

  static const String appName = 'Финансы';
  static const String currencySymbol = '₸';
  static const String income = 'Доход';
  static const String expense = 'Расход';
  static const String dashboard = 'Главная';
  static const String transactions = 'Операции';
  static const String credits = 'Кредиты';
  static const String tips = 'Советы';
  static const String analytics = 'Аналитика';
}
