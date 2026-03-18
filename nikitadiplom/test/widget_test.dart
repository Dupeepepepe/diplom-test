import 'package:flutter_test/flutter_test.dart';
import 'package:nikitadiplom/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FinanceApp());
    expect(find.text('Главная'), findsOneWidget);
  });
}
