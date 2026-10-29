import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/domain/models/empresa.dart';
import 'package:nexo_future_app/ui/app.dart';

import '../../apoio/autenticacao_falsa.dart';
import '../../apoio/perfis_falsos.dart';
import '../../apoio/tela_alta.dart';

void main() {
  // Mudança de requisito da Sprint 2: o visitante vê vagas e cursos sem conta;
  // candidatar-se e as telas de empresa e oficina pedem login.
  group('Visitante sem login', () {
    late AutenticacaoFalsa auth;
    late PerfisFalsos perfis;

    setUp(() {
      auth = AutenticacaoFalsa();
      perfis = PerfisFalsos();
      usarTelaAlta();
    });
    tearDown(restaurarTela);

    Future<void> abrirApp(WidgetTester tester) async {
      await tester.pumpWidget(
        NexoFutureApp(autenticacao: auth, perfis: perfis),
      );
      await tester.pumpAndSettle();
    }

    Future<void> abrirLaminador(WidgetTester tester) async {
      await tester.tap(find.text('Laminador'));
      await tester.pumpAndSettle();
    }

    Future<void> preencherLogin(WidgetTester tester) async {
      await tester.enterText(
        find.widgetWithText(TextField, 'E-mail'),
        'ana@email.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Senha'),
        'senha-certa',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
      await tester.pumpAndSettle();
    }

    testWidgets('o app abre nas vagas, com o botão Entrar no topo', (
      tester,
    ) async {
      await abrirApp(tester);

      expect(find.text('Vagas'), findsOneWidget);
      expect(find.text('Laminador'), findsOneWidget);
      expect(find.byKey(const Key('botao-entrar')), findsOneWidget);
      expect(find.byTooltip('Minhas candidaturas'), findsNothing);
      expect(
        find.text('Encontre uma vaga e o curso que leva até ela.'),
        findsOneWidget,
      );
    });

    testWidgets('o visitante vê o detalhe da vaga e os cursos', (tester) async {
      await abrirApp(tester);
      await abrirLaminador(tester);

      expect(find.text('Cursos vinculados'), findsOneWidget);
      expect(find.text('Laminação em fibra de vidro'), findsOneWidget);
      expect(find.text('Candidatar-se'), findsOneWidget);
    });

    testWidgets('candidatar-se sem login pede para entrar ou criar conta', (
      tester,
    ) async {
      await abrirApp(tester);
      await abrirLaminador(tester);

      await tester.tap(find.text('Candidatar-se'));
      await tester.pumpAndSettle();

      expect(
        find.text('Entre ou crie sua conta para se candidatar.'),
        findsOneWidget,
      );
      expect(find.widgetWithText(FilledButton, 'Entrar'), findsOneWidget);
      expect(
        find.widgetWithText(OutlinedButton, 'Criar conta'),
        findsOneWidget,
      );
      expect(find.textContaining('Você se candidatou'), findsNothing);
    });

    testWidgets('entrar pelo aviso volta para a vaga e libera a candidatura', (
      tester,
    ) async {
      await abrirApp(tester);
      await abrirLaminador(tester);
      await tester.tap(find.text('Candidatar-se'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
      await tester.pumpAndSettle();
      await preencherLogin(tester);

      expect(find.text('Cursos vinculados'), findsOneWidget);
      await tester.tap(find.text('Candidatar-se'));
      await tester.pumpAndSettle();
      expect(find.text('Você se candidatou à vaga Laminador.'), findsOneWidget);
    });

    testWidgets('criar conta pelo aviso abre a escolha do perfil', (
      tester,
    ) async {
      await abrirApp(tester);
      await abrirLaminador(tester);
      await tester.tap(find.text('Candidatar-se'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(OutlinedButton, 'Criar conta'));
      await tester.pumpAndSettle();

      expect(find.text('Como você vai usar o Nexo Future?'), findsOneWidget);
    });

    testWidgets('quem entrou vê Minhas candidaturas e pode sair', (
      tester,
    ) async {
      await abrirApp(tester);
      await tester.tap(find.byKey(const Key('botao-entrar')));
      await tester.pumpAndSettle();
      await preencherLogin(tester);

      expect(find.text('Vagas'), findsOneWidget);
      expect(find.byTooltip('Minhas candidaturas'), findsOneWidget);
      expect(find.byKey(const Key('botao-entrar')), findsNothing);

      await tester.tap(find.byTooltip('Sair'));
      await tester.pumpAndSettle();

      expect(auth.saidas, 1);
      expect(find.byKey(const Key('botao-entrar')), findsOneWidget);
      expect(find.byTooltip('Minhas candidaturas'), findsNothing);
    });

    testWidgets('a empresa sai do painel e volta para as vagas', (
      tester,
    ) async {
      perfis.empresas['uid-ana@email.com'] = PerfilEmpresa(
        id: 'uid-ana@email.com',
        nome: 'Estaleiro Foz Azul Ltda.',
        cnpj: '11222333000181',
        setor: 'Naval',
        recrutador: 'Marcos Pereira',
        email: 'ana@email.com',
        cidade: 'Itajaí',
        aceitePoliticaEm: DateTime(2026, 10, 29),
      );
      await abrirApp(tester);
      await tester.tap(find.byKey(const Key('botao-entrar')));
      await tester.pumpAndSettle();
      await preencherLogin(tester);
      expect(find.text('Estaleiro Foz Azul Ltda.'), findsOneWidget);

      await tester.tap(find.byTooltip('Sair'));
      await tester.pumpAndSettle();

      expect(find.text('Vagas'), findsOneWidget);
      expect(find.byKey(const Key('botao-entrar')), findsOneWidget);
    });

    testWidgets('Já confirmei, depois do cadastro, leva para o login', (
      tester,
    ) async {
      await abrirApp(tester);
      await tester.tap(find.byKey(const Key('botao-entrar')));
      await tester.pumpAndSettle();
      // Conta que ainda não confirmou o e-mail.
      await tester.enterText(
        find.widgetWithText(TextField, 'E-mail'),
        'novo@email.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Senha'),
        'senha-certa',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
      await tester.pumpAndSettle();
      expect(find.text('Confirme seu e-mail'), findsOneWidget);

      await tester.tap(find.text('Já confirmei'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, 'Senha'), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Vagas'), findsOneWidget);
    });
  });
}
