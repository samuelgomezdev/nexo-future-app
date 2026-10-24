import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nexo_future_app/ui/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('RNF0009: candidatura em até 3 toques a partir da tela inicial', () {
    testWidgets('abre o app, toca na primeira vaga disponível, toca em '
        'Candidatar-se e vê a confirmação', (tester) async {
      var toques = 0;
      Future<void> tocar(Finder alvo) async {
        toques++;
        await tester.tap(alvo);
        await tester.pumpAndSettle();
      }

      await tester.pumpWidget(const NexoFutureApp());
      await tester.pumpAndSettle();
      expect(find.text('Vagas'), findsOneWidget);

      // 1º toque: a primeira vaga que está aceitando candidaturas.
      final primeiraDisponivel = find
          .ancestor(
            of: find.text('Aceitando candidaturas'),
            matching: find.byType(ListTile),
          )
          .first;
      await tocar(primeiraDisponivel);
      expect(find.text('Cursos vinculados'), findsOneWidget);

      // 2º toque: o botão de candidatura.
      await tocar(find.text('Candidatar-se'));

      expect(find.text('Candidatura enviada'), findsOneWidget);
      expect(toques, lessThanOrEqualTo(3));
    });
  });
}
