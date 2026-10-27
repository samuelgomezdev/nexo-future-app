import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/ui/app.dart';

import '../../apoio/autenticacao_falsa.dart';

void main() {
  group('Tela de login (protótipo A2, A3 e A4)', () {
    Future<void> abrirApp(WidgetTester tester) async {
      await tester.pumpWidget(NexoFutureApp(autenticacao: AutenticacaoFalsa()));
      await tester.pumpAndSettle();
    }

    Future<void> entrar(WidgetTester tester, String email, String senha) async {
      await tester.enterText(find.widgetWithText(TextField, 'E-mail'), email);
      await tester.enterText(find.widgetWithText(TextField, 'Senha'), senha);
      await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
      await tester.pumpAndSettle();
    }

    testWidgets('com login, o app abre na tela Entrar', (tester) async {
      await abrirApp(tester);

      expect(find.text('Entrar'), findsWidgets);
      expect(find.widgetWithText(TextField, 'E-mail'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Senha'), findsOneWidget);
    });

    testWidgets('com a senha certa, vai para a lista de vagas', (tester) async {
      await abrirApp(tester);

      await entrar(tester, 'ana@email.com', 'senha-certa');

      expect(find.text('Vagas'), findsOneWidget);
    });

    testWidgets(
      'com a senha errada, avisa no campo quantas tentativas restam',
      (tester) async {
        await abrirApp(tester);

        await entrar(tester, 'ana@email.com', 'senha-errada');

        expect(
          find.text('E-mail ou senha incorretos. Restam 4 tentativas.'),
          findsOneWidget,
        );
      },
    );

    testWidgets('na 5ª senha errada, mostra o bloqueio com o tempo restante', (
      tester,
    ) async {
      await abrirApp(tester);

      for (var i = 0; i < 5; i++) {
        await entrar(tester, 'ana@email.com', 'senha-errada');
      }

      expect(find.text('Acesso bloqueado por segurança'), findsOneWidget);
      expect(find.text('15:00'), findsOneWidget);
    });

    testWidgets('com o e-mail não confirmado, pede a confirmação', (
      tester,
    ) async {
      await abrirApp(tester);

      await entrar(tester, 'novo@email.com', 'senha-certa');

      expect(find.text('Confirme seu e-mail'), findsOneWidget);
    });
  });
}
