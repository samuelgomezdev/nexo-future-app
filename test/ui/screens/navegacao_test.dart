import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/ui/app.dart';

void main() {
  group('Telas F1 a F4', () {
    testWidgets('abre na lista de vagas com a primeira página do seed', (
      tester,
    ) async {
      await tester.pumpWidget(const NexoFutureApp());

      expect(find.text('Vagas'), findsOneWidget);
      expect(find.text('Laminador'), findsOneWidget);
    });

    testWidgets('pesquisar "solda" mostra só as vagas de solda', (
      tester,
    ) async {
      await tester.pumpWidget(const NexoFutureApp());

      await tester.enterText(find.byType(TextField), 'solda');
      await tester.pump();

      expect(find.text('Soldador'), findsWidgets);
      expect(find.text('Laminador'), findsNothing);
    });

    testWidgets('tocar numa vaga abre o detalhe com os cursos vinculados', (
      tester,
    ) async {
      await tester.pumpWidget(const NexoFutureApp());

      await tester.tap(find.text('Laminador'));
      await tester.pumpAndSettle();

      expect(find.text('Cursos vinculados'), findsOneWidget);
      expect(find.text('Laminação em fibra de vidro'), findsOneWidget);
      expect(find.text('Candidatar-se'), findsOneWidget);
    });

    testWidgets('o atalho leva para Minhas candidaturas, ainda vazia', (
      tester,
    ) async {
      await tester.pumpWidget(const NexoFutureApp());

      await tester.tap(find.byTooltip('Minhas candidaturas'));
      await tester.pumpAndSettle();

      expect(
        find.text('Você ainda não se candidatou a nenhuma vaga.'),
        findsOneWidget,
      );
    });
  });
}
