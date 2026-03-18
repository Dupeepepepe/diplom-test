import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/tip_card.dart';

class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  List<Map<String, dynamic>> _tips = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTips();
  }

  Future<void> _loadTips() async {
    try {
      final jsonString = await rootBundle.loadString('assets/tips.json');
      final List<dynamic> data = json.decode(jsonString);
      final tips = data.cast<Map<String, dynamic>>();
      tips.shuffle(Random());
      setState(() {
        _tips = tips;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Финансовые советы'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: () {
              setState(() {
                _tips.shuffle(Random());
              });
            },
            tooltip: 'Перемешать',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _tips.isEmpty
              ? const Center(child: Text('Нет советов'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _tips.length,
                  itemBuilder: (context, index) {
                    final tip = _tips[index];
                    return TipCard(
                      title: tip['title'] as String,
                      text: tip['text'] as String,
                    );
                  },
                ),
    );
  }
}
