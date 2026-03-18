import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'transactions_screen.dart';
import 'credits_screen.dart';
import 'tips_screen.dart';
import 'analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardScreen(),
    TransactionsScreen(),
    CreditsScreen(),
    TipsScreen(),
    AnalyticsScreen(),
  ];

  final _labels = const [
    'Главная',
    'Операции',
    'Кредиты',
    'Советы',
    'Аналитика',
  ];

  final _icons = const [
    Icons.dashboard,
    Icons.receipt_long,
    Icons.credit_card,
    Icons.lightbulb_outline,
    Icons.analytics,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: List.generate(
          _labels.length,
          (i) => BottomNavigationBarItem(
            icon: Icon(_icons[i]),
            label: _labels[i],
          ),
        ),
      ),
    );
  }
}
