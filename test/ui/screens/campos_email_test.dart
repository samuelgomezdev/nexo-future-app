import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/ui/app.dart';

import '../../apoio/autenticacao_falsa.dart';
import '../../apoio/perfis_falsos.dart';
import '../../apoio/tela_alta.dart';

void main() {
  // No celular, o corretor do teclado trocava o e-mail digitado (inseria
  // espaço). Sem correção automática, mas com as sugestões e o preenchimento
  // automático, para a pessoa não precisar digitar o e-mail inteiro.
  group('Campos de e-mail', () {
    setUp(usarTelaAlta);
    tearDown(restaurarTela);

    Future<void> abrirApp(WidgetTester tester) async {
      await tester.pumpWidget(
        NexoFutureApp(
          autenticacao: AutenticacaoFalsa(),
          perfis: PerfisFalsos(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('botao-entrar')));
      await tester.pumpAndSettle();
    }

    Future<void> abrirCadastro(WidgetTester tester, String perfil) async {
      await abrirApp(tester);
      await tester.tap(find.text('Cadastre-se'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(perfil));
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
    }

    void conferirCampo(WidgetTester tester, String rotulo) {
      final campo = tester.widget<TextField>(
        find.widgetWithText(TextField, rotulo),
      );
      expect(campo.autocorrect, isFalse, reason: '$rotulo com autocorreção');
      expect(
        campo.enableSuggestions,
        isTrue,
        reason: '$rotulo sem as sugestões do teclado',
      );
      expect(
        campo.autofillHints,
        contains(AutofillHints.email),
        reason: '$rotulo sem preenchimento automático',
      );
    }

    testWidgets('no login', (tester) async {
      await abrirApp(tester);
      conferirCampo(tester, 'E-mail');
    });

    testWidgets('no cadastro do jovem', (tester) async {
      await abrirCadastro(tester, 'Sou jovem');
      conferirCampo(tester, 'E-mail');
    });

    testWidgets('no cadastro da empresa', (tester) async {
      await abrirCadastro(tester, 'Sou empresa');
      conferirCampo(tester, 'E-mail do recrutador *');
    });

    testWidgets('no cadastro da oficina', (tester) async {
      await abrirCadastro(tester, 'Sou oficina');
      conferirCampo(tester, 'E-mail *');
    });
  });
}
