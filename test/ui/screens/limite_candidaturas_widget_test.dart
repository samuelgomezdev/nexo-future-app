import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/ui/app.dart';

/// Vagas do início do seed que aceitam candidatura.
const cincoVagas = [
  'Laminador',
  'Pintor Naval',
  'Marceneiro Náutico',
  'Motorista CNH D',
  'Mecânico Diesel',
];

void main() {
  group('UC0007 E1: aviso de limite de candidaturas na tela', () {
    setUp(() {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      // Tela alta para a primeira página de vagas caber sem rolar.
      binding.platformDispatcher.views.first.physicalSize = const Size(
        1080,
        2400,
      );
      binding.platformDispatcher.views.first.devicePixelRatio = 1;
    });

    tearDown(() {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.platformDispatcher.views.first.resetPhysicalSize();
      binding.platformDispatcher.views.first.resetDevicePixelRatio();
    });

    Future<void> abrirVaga(WidgetTester tester, String titulo) async {
      await tester.tap(find.text(titulo).first);
      await tester.pumpAndSettle();
    }

    Future<void> candidatarNasCinco(WidgetTester tester) async {
      for (final titulo in cincoVagas) {
        await abrirVaga(tester, titulo);
        await tester.tap(find.text('Candidatar-se'));
        await tester.pumpAndSettle();
        expect(find.text('Candidatura enviada'), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();
      }
    }

    testWidgets('na 6ª candidatura mostra a mensagem e o botão Minhas '
        'candidaturas', (tester) async {
      await tester.pumpWidget(const NexoFutureApp());
      await candidatarNasCinco(tester);

      await abrirVaga(tester, 'Soldador');
      await tester.tap(find.text('Candidatar-se'));
      await tester.pumpAndSettle();

      expect(find.text('Limite de candidaturas'), findsOneWidget);
      expect(
        find.text(
          'Você já tem 5 candidaturas ativas. '
          'Desista de uma para se candidatar a outra vaga.',
        ),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(FilledButton, 'Minhas candidaturas'),
        findsOneWidget,
      );
    });

    testWidgets('o botão do aviso leva para Minhas candidaturas', (
      tester,
    ) async {
      await tester.pumpWidget(const NexoFutureApp());
      await candidatarNasCinco(tester);
      await abrirVaga(tester, 'Soldador');
      await tester.tap(find.text('Candidatar-se'));
      await tester.pumpAndSettle();

      await tester.tap(
        find.widgetWithText(FilledButton, 'Minhas candidaturas'),
      );
      await tester.pumpAndSettle();

      expect(find.text('5 de 5 candidaturas ativas'), findsOneWidget);
    });

    testWidgets('desistir de uma libera a candidatura na vaga que faltava', (
      tester,
    ) async {
      await tester.pumpWidget(const NexoFutureApp());
      await candidatarNasCinco(tester);
      await abrirVaga(tester, 'Soldador');
      await tester.tap(find.text('Candidatar-se'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, 'Minhas candidaturas'),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Desistir').first);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Desistir'));
      await tester.pumpAndSettle();
      expect(find.text('4 de 5 candidaturas ativas'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Candidatar-se'));
      await tester.pumpAndSettle();

      expect(find.text('Limite de candidaturas'), findsNothing);
      expect(find.text('Candidatura enviada'), findsOneWidget);
    });
  });
}
