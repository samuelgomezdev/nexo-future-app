import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/ui/app.dart';

import '../../apoio/autenticacao_falsa.dart';
import '../../apoio/perfis_falsos.dart';
import '../../apoio/tela_alta.dart';

void main() {
  group('Cadastro da empresa (protótipo C3)', () {
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
      await tester.tap(find.text('Sou empresa'));
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
    }

    Future<void> escolher(
      WidgetTester tester,
      String chave,
      String opcao,
    ) async {
      await tester.tap(find.byKey(Key(chave)));
      await tester.pumpAndSettle();
      await tester.tap(find.text(opcao).last);
      await tester.pumpAndSettle();
    }

    Future<void> preencherEtapa1(
      WidgetTester tester, {
      String email = 'rh@fozazul.com',
    }) async {
      await tester.enterText(
        find.widgetWithText(TextField, 'Razão social *'),
        'Estaleiro Foz Azul Ltda.',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'CNPJ *'),
        '11222333000181',
      );
      await escolher(tester, 'campo-setor', 'Naval');
      await tester.enterText(
        find.widgetWithText(TextField, 'E-mail do recrutador *'),
        email,
      );
    }

    Future<void> preencherEtapa2(WidgetTester tester) async {
      await tester.enterText(
        find.widgetWithText(TextField, 'Nome do recrutador *'),
        'Marcos Pereira',
      );
      await escolher(tester, 'campo-cidade', 'Itajaí');
      await tester.enterText(
        find.widgetWithText(TextField, 'Senha *'),
        'senha1234',
      );
      await tester.tap(find.text('Li e aceito a Política de Privacidade'));
      await tester.pumpAndSettle();
    }

    testWidgets('começa na etapa 1, com os dados da empresa', (tester) async {
      await abrirCadastro(tester);

      expect(find.text('Etapa 1 de 2 · Dados da empresa'), findsOneWidget);
      expect(find.text('Usaremos para enviar a validação.'), findsOneWidget);
    });

    testWidgets('sem preencher, aponta os campos da etapa 1 e não avança', (
      tester,
    ) async {
      await abrirCadastro(tester);

      await tester.tap(find.text('Próxima etapa'));
      await tester.pumpAndSettle();

      expect(find.text('Informe a razão social.'), findsOneWidget);
      expect(find.text('Informe um CNPJ válido.'), findsOneWidget);
      expect(find.text('Escolha o setor da empresa.'), findsOneWidget);
      expect(find.text('Informe um e-mail válido.'), findsOneWidget);
      expect(find.text('Corrija 4 campos para continuar.'), findsOneWidget);
      expect(find.text('Etapa 1 de 2 · Dados da empresa'), findsOneWidget);
    });

    testWidgets('com um campo errado, o aviso fala em 1 campo', (tester) async {
      await abrirCadastro(tester);
      await preencherEtapa1(tester);
      await tester.enterText(
        find.widgetWithText(TextField, 'CNPJ *'),
        '11222333000182',
      );

      await tester.tap(find.text('Próxima etapa'));
      await tester.pumpAndSettle();

      expect(find.text('Corrija 1 campo para continuar.'), findsOneWidget);
    });

    testWidgets('o CNPJ ganha a pontuação ao digitar só números', (
      tester,
    ) async {
      await abrirCadastro(tester);

      await tester.enterText(
        find.widgetWithText(TextField, 'CNPJ *'),
        '11222333000181',
      );
      await tester.pumpAndSettle();

      expect(find.text('11.222.333/0001-81'), findsOneWidget);
    });

    testWidgets('com tudo certo, cria a conta e pede a confirmação do e-mail', (
      tester,
    ) async {
      await abrirCadastro(tester);
      await preencherEtapa1(tester);
      await tester.tap(find.text('Próxima etapa'));
      await tester.pumpAndSettle();

      expect(find.text('Etapa 2 de 2 · Acesso'), findsOneWidget);
      await preencherEtapa2(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Criar conta'));
      await tester.pumpAndSettle();

      expect(find.text('Confirme seu e-mail'), findsOneWidget);
      expect(auth.confirmacoesEnviadas, ['rh@fozazul.com']);
      final empresa = perfis.empresas.values.single;
      expect(empresa.cnpj, '11222333000181');
      expect(empresa.setor, 'Naval');
      expect(empresa.recrutador, 'Marcos Pereira');
    });

    testWidgets('na etapa 2, faltando campos, aponta os erros dela', (
      tester,
    ) async {
      await abrirCadastro(tester);
      await preencherEtapa1(tester);
      await tester.tap(find.text('Próxima etapa'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Criar conta'));
      await tester.pumpAndSettle();

      expect(
        find.text('Informe o nome de quem faz o cadastro.'),
        findsOneWidget,
      );
      expect(find.text('Escolha a cidade da empresa.'), findsOneWidget);
      expect(find.text('Corrija 4 campos para continuar.'), findsOneWidget);
      expect(perfis.empresas, isEmpty);
    });

    testWidgets('e-mail já cadastrado volta para a etapa 1 com o erro', (
      tester,
    ) async {
      await abrirCadastro(tester);
      await preencherEtapa1(tester, email: 'ana@email.com');
      await tester.tap(find.text('Próxima etapa'));
      await tester.pumpAndSettle();
      await preencherEtapa2(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Criar conta'));
      await tester.pumpAndSettle();

      expect(find.text('Etapa 1 de 2 · Dados da empresa'), findsOneWidget);
      expect(
        find.text('Já existe uma conta com este e-mail. Tente entrar.'),
        findsOneWidget,
      );
    });

    testWidgets('voltar na etapa 2 mostra a etapa 1 com os dados', (
      tester,
    ) async {
      await abrirCadastro(tester);
      await preencherEtapa1(tester);
      await tester.tap(find.text('Próxima etapa'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();

      expect(find.text('Etapa 1 de 2 · Dados da empresa'), findsOneWidget);
      expect(find.text('Estaleiro Foz Azul Ltda.'), findsOneWidget);
    });
  });
}
