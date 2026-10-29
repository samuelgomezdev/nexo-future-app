import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/ui/app.dart';

import '../../apoio/autenticacao_falsa.dart';
import '../../apoio/perfis_falsos.dart';
import '../../apoio/tela_alta.dart';

void main() {
  group('Escolha do perfil (protótipo C1)', () {
    setUp(usarTelaAlta);
    tearDown(restaurarTela);

    Future<void> abrirEscolha(WidgetTester tester) async {
      await tester.pumpWidget(
        NexoFutureApp(
          autenticacao: AutenticacaoFalsa(),
          perfis: PerfisFalsos(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('botao-entrar')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cadastre-se'));
      await tester.pumpAndSettle();
    }

    testWidgets('o Cadastre-se do login abre a escolha dos três perfis', (
      tester,
    ) async {
      await abrirEscolha(tester);

      expect(find.text('Como você vai usar o Nexo Future?'), findsOneWidget);
      expect(
        find.text('Escolha o seu perfil. Cada um vê telas diferentes.'),
        findsOneWidget,
      );
      expect(find.text('Sou jovem'), findsOneWidget);
      expect(find.text('Sou empresa'), findsOneWidget);
      expect(find.text('Sou oficina'), findsOneWidget);
      expect(
        find.text('Quero publicar vagas e aprovar cursos.'),
        findsOneWidget,
      );
    });

    testWidgets('Sou jovem leva ao cadastro do jovem', (tester) async {
      await abrirEscolha(tester);

      await tester.tap(find.text('Sou jovem'));
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      expect(find.text('Data de nascimento'), findsOneWidget);
    });

    testWidgets('Sou empresa leva ao cadastro da empresa', (tester) async {
      await abrirEscolha(tester);

      await tester.tap(find.text('Sou empresa'));
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      expect(find.text('Cadastro da empresa'), findsOneWidget);
    });

    testWidgets('Sou oficina leva ao cadastro da oficina', (tester) async {
      await abrirEscolha(tester);

      await tester.tap(find.text('Sou oficina'));
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      expect(find.text('Cadastro da oficina'), findsOneWidget);
    });
  });
}
