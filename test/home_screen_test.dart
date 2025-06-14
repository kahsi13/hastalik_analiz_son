import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hastalik_analiz/screens/home_screen.dart';

void main() {
  testWidgets('Home screen shows menu options', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('🍅 Domates Analiz'), findsOneWidget);
    expect(find.text('💬 BERT Chat Teşhis'), findsOneWidget);
    expect(find.text('📚 Hastalık Kütüphanesi'), findsOneWidget);
  });
}
