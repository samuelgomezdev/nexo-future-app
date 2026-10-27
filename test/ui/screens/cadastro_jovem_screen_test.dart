import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/ui/app.dart';

import '../../apoio/autenticacao_falsa.dart';
import '../../apoio/perfis_falsos.dart';

void main() {
  group('Tela de cadastro do jovem (protótipo C2)', () {
    late AutenticacaoFalsa auth;
    late PerfisFalsos perfis;

    setUp(() {
      auth = AutenticacaoFalsa();
      perfis = PerfisFalsos();
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      // Tela alta para o formulário caber sem rolar.
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

    Future<void> abrirCadastro(WidgetTester tester) async {
      await tester.pumpWidget(
        NexoFutureApp(autenticacao: auth, perfis: perfis),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cadastre-se'));
      await tester.pumpAndSettle();
    }

    Future<void> preencher(
      WidgetTester tester, {
      String nascimento = '10/05/2000',
    }) async {
      await tester.enterText(
        find.widgetWithText(TextField, 'Nome completo'),
        'Carla Lima',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'E-mail'),
        'carla@email.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Senha'),
        'senha1234',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Data de nascimento'),
        nascimento,
      );
      await tester.tap(find.byKey(const Key('campo-cidade')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Navegantes').last);
      await tester.pumpAndSettle();
    }

    testWidgets('o login leva ao cadastro pelo link Cadastre-se', (
      tester,
    ) async {
      await abrirCadastro(tester);

      expect(find.text('Criar conta'), findsWidgets);
    });

    testWidgets('sem preencher, aponta os campos obrigatórios', (tester) async {
      await abrirCadastro(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Criar conta'));
      await tester.pumpAndSettle();

      expect(find.text('Informe seu nome completo.'), findsOneWidget);
      expect(find.text('Informe um e-mail válido.'), findsOneWidget);
      expect(find.text('Escolha sua cidade.'), findsOneWidget);
      expect(
        find.text('Aceite a Política de Privacidade para continuar.'),
        findsOneWidget,
      );
    });

    testWidgets(
      'para quem tem menos de 18 anos, pede a autorização do responsável',
      (tester) async {
        await abrirCadastro(tester);
        expect(
          find.text('Meu responsável autorizou este cadastro'),
          findsNothing,
        );

        await tester.enterText(
          find.widgetWithText(TextField, 'Data de nascimento'),
          '10/05/2011',
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Meu responsável autorizou este cadastro'),
          findsOneWidget,
        );
      },
    );

    testWidgets('a Política de Privacidade abre pelo link do aceite', (
      tester,
    ) async {
      await abrirCadastro(tester);

      await tester.tap(find.text('Ler a Política de Privacidade'));
      await tester.pumpAndSettle();

      expect(find.text('Política de Privacidade'), findsOneWidget);
      expect(find.textContaining('não pedimos CPF'), findsOneWidget);
    });

    testWidgets('com tudo certo, cria a conta e pede a confirmação do e-mail', (
      tester,
    ) async {
      await abrirCadastro(tester);
      await preencher(tester);
      await tester.tap(find.text('Li e aceito a Política de Privacidade'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Criar conta'));
      await tester.pumpAndSettle();

      expect(find.text('Confirme seu e-mail'), findsOneWidget);
      expect(auth.confirmacoesEnviadas, ['carla@email.com']);
      expect(perfis.jovens.values.single.cidade, 'Navegantes');
    });
  });
}
