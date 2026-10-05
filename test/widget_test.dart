import 'package:cotacao_cripto3/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('mostra navegação principal', (tester) async {
    await tester.pumpWidget(const CotacaoCripto3App());

    expect(find.text('Início'), findsOneWidget);
    expect(find.text('Moedas'), findsOneWidget);
    expect(find.text('Conversão'), findsOneWidget);
    expect(find.text('Integração'), findsOneWidget);
  });
}
