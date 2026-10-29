import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/ui/app.dart';

import '../../apoio/autenticacao_falsa.dart';
import '../../apoio/perfis_falsos.dart';
import '../../apoio/tela_alta.dart';

void main() {
  group('Cadastro da oficina (protótipo C4)', () {
    late AutenticacaoFalsa auth;
    late PerfisFalsos perfis;

    setUp(() {
      auth = AutenticacaoFalsa();
      perfis = PerfisFalsos();
      usarTelaAlta();
    });
    tearDown(restaurarTela);

    Future<void> abrirCadastro(WidgetTester tester) async {
      await tester.pumpWidget(
        NexoFutureApp(autenticacao: auth, perfis: perfis),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cadastre-se'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sou oficina'));
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
    }

    Future<void> preencherEtapa1(WidgetTester tester) async {
      await tester.enterText(
        find.widgetWithText(TextField, 'Nome da oficina *'),
        'Oficina Escola Mãos do Porto',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'CNPJ *'),
        '11222333000181',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Nome do responsável *'),
        'Rita Moraes',
      );
      await tester.tap(find.byKey(const Key('campo-cidade')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Itajaí').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'E-mail *'),
        'contato@maosdoporto.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Senha *'),
        'senha1234',
      );
      await tester.tap(find.text('Li e aceito a Política de Privacidade'));
      await tester.pumpAndSettle();
    }

    Future<void> irParaEtapa2(WidgetTester tester) async {
      await abrirCadastro(tester);
      await preencherEtapa1(tester);
      await tester.tap(find.text('Próxima etapa'));
      await tester.pumpAndSettle();
    }

    testWidgets('sem preencher, aponta os campos da etapa 1 e não avança', (
      tester,
    ) async {
      await abrirCadastro(tester);
      expect(find.text('Etapa 1 de 2 · Dados da oficina'), findsOneWidget);

      await tester.tap(find.text('Próxima etapa'));
      await tester.pumpAndSettle();

      expect(find.text('Informe o nome da oficina.'), findsOneWidget);
      expect(
        find.text('Informe o nome de quem responde pela oficina.'),
        findsOneWidget,
      );
      expect(find.text('Escolha a cidade da oficina.'), findsOneWidget);
      expect(find.text('Corrija 7 campos para continuar.'), findsOneWidget);
      expect(find.text('Etapa 1 de 2 · Dados da oficina'), findsOneWidget);
    });

    testWidgets('corrigir os campos tira os erros deles na hora', (
      tester,
    ) async {
      await abrirCadastro(tester);
      await tester.tap(find.text('Próxima etapa'));
      await tester.pumpAndSettle();

      await preencherEtapa1(tester);

      expect(find.textContaining('Corrija'), findsNothing);
      expect(find.text('Informe o nome da oficina.'), findsNothing);
      expect(
        find.text('Aceite a Política de Privacidade para continuar.'),
        findsNothing,
      );
    });

    testWidgets('o erro do alvará some ao editar o número', (tester) async {
      await irParaEtapa2(tester);
      await tester.enterText(
        find.widgetWithText(TextField, 'Número do alvará'),
        'AE-2026-0042',
      );
      await tester.tap(find.text('Concluir cadastro'));
      await tester.pumpAndSettle();
      expect(find.text('Informe a validade do alvará.'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Número do alvará'),
        'AE-2026-0043',
      );
      await tester.pump();

      expect(find.text('Informe a validade do alvará.'), findsNothing);
    });

    testWidgets('a etapa 2 pede o alvará e explica a RN0003', (tester) async {
      await irParaEtapa2(tester);

      expect(find.text('Etapa 2 de 2 · Documentação'), findsOneWidget);
      expect(find.text('Informe o alvará de ensino'), findsOneWidget);
      expect(
        find.text(
          'Sem o alvará em dia, a oficina pode entrar no app, mas não publica cursos (RN0003).',
        ),
        findsOneWidget,
      );
    });

    testWidgets('concluir com o alvará salva a oficina com ele', (
      tester,
    ) async {
      await irParaEtapa2(tester);
      await tester.enterText(
        find.widgetWithText(TextField, 'Número do alvará'),
        'AE-2026-0042',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Validade'),
        '01032099',
      );
      await tester.pumpAndSettle();
      expect(find.text('01/03/2099'), findsOneWidget);

      await tester.tap(find.text('Concluir cadastro'));
      await tester.pumpAndSettle();

      expect(find.text('Confirme seu e-mail'), findsOneWidget);
      final oficina = perfis.oficinas.values.single;
      expect(oficina.alvara?.numero, 'AE-2026-0042');
      expect(oficina.alvara?.validade, DateTime(2099, 3, 1));
    });

    testWidgets('enviar depois cadastra a oficina sem o alvará', (
      tester,
    ) async {
      await irParaEtapa2(tester);
      await tester.enterText(
        find.widgetWithText(TextField, 'Número do alvará'),
        'AE-RASCUNHO',
      );

      await tester.tap(find.text('Enviar depois'));
      await tester.pumpAndSettle();

      expect(find.text('Confirme seu e-mail'), findsOneWidget);
      expect(perfis.oficinas.values.single.alvara, isNull);
    });

    testWidgets('alvará vencido é apontado e não cadastra', (tester) async {
      await irParaEtapa2(tester);
      await tester.enterText(
        find.widgetWithText(TextField, 'Número do alvará'),
        'AE-2020-0001',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Validade'),
        '01/01/2020',
      );

      await tester.tap(find.text('Concluir cadastro'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Este alvará já venceu. Informe o alvará em dia ou deixe para enviar depois.',
        ),
        findsOneWidget,
      );
      expect(perfis.oficinas, isEmpty);
    });
  });
}
