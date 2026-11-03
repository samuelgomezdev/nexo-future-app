import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/domain/models/curso.dart';
import 'package:nexo_future_app/domain/models/jovem.dart';

import '../../apoio/app_de_teste.dart';
import '../../apoio/candidaturas_falsas.dart';
import '../../apoio/perfis_falsos.dart';
import '../../apoio/tela_alta.dart';
import '../../apoio/vagas_falsas.dart';

void main() {
  // RF0008 e RF0017: as candidaturas ficam na conta do jovem e contam nas
  // posições da vaga publicada.
  group('Candidaturas salvas na conta do jovem', () {
    late PerfisFalsos perfis;
    late VagasFalsas vagas;
    late CandidaturasFalsas candidaturas;

    const pintor = Vaga(
      id: 'vaga-pintor',
      titulo: 'Pintor(a) naval',
      empresa: 'Estaleiro Foz Azul',
      area: 'Naval',
      cidade: 'Itajaí',
      qualificacao: 'Pintura de cascos.',
      situacao: SituacaoVaga.aguardandoIngresso,
      empresaId: 'uid-marcos',
      posicoes: 1,
      cursos: [
        Curso(
          id: 'curso-pintura',
          nome: 'Pintura naval',
          oficina: 'Oficina Escola Mãos do Porto',
          cargaHoraria: 32,
        ),
      ],
    );

    setUp(() {
      perfis = PerfisFalsos()
        ..jovens[idTeste] = PerfilJovem(
          id: idTeste,
          nome: 'Ana Souza',
          email: emailTeste,
          cidade: 'Itajaí',
          dataNascimento: DateTime(2004, 5, 10),
          autorizacaoResponsavel: false,
          aceitePoliticaEm: DateTime(2026, 11, 1),
        );
      vagas = VagasFalsas([pintor]);
      candidaturas = CandidaturasFalsas(vagas);
      usarTelaAlta();
    });
    tearDown(restaurarTela);

    Future<void> entrar(WidgetTester tester) => entrarNoApp(
      tester,
      perfis: perfis,
      vagas: vagas,
      candidaturas: candidaturas,
    );

    Future<void> candidatarAoPintor(WidgetTester tester) async {
      await tester.tap(find.text('Pintor(a) naval'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Candidatar-se'));
      await tester.pumpAndSettle();
    }

    testWidgets('a candidatura que completa as posições deixa a vaga lotada', (
      tester,
    ) async {
      await entrar(tester);

      await candidatarAoPintor(tester);

      expect(find.text('Candidatura enviada'), findsOneWidget);
      expect(vagas.vagas['vaga-pintor']?.situacao, SituacaoVaga.lotada);
      expect(await candidaturas.carregar(idTeste), ['vaga-pintor']);

      await tester.pageBack();
      await tester.pumpAndSettle();
      final cartao = find.ancestor(
        of: find.text('Pintor(a) naval'),
        matching: find.byType(ListTile),
      );
      expect(
        find.descendant(of: cartao, matching: find.text('Lotada')),
        findsOneWidget,
      );
    });

    testWidgets('o detalhe mostra Lotada logo depois da candidatura', (
      tester,
    ) async {
      await entrar(tester);

      await candidatarAoPintor(tester);

      expect(find.text('Lotada'), findsOneWidget);
      expect(find.text('Aceitando candidaturas'), findsNothing);
    });

    testWidgets('quem sai e entra de novo encontra as candidaturas', (
      tester,
    ) async {
      await entrar(tester);
      await candidatarAoPintor(tester);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Sair'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Minhas candidaturas'), findsNothing);

      await tester.tap(find.byKey(const Key('botao-entrar')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'E-mail'),
        emailTeste,
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Senha'),
        'senha-certa',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Minhas candidaturas'));
      await tester.pumpAndSettle();
      expect(find.text('1 de 5 candidaturas ativas'), findsOneWidget);
      expect(find.text('Pintor(a) naval'), findsOneWidget);
    });

    testWidgets('sem internet, avisa e a vaga continua disponível', (
      tester,
    ) async {
      await entrar(tester);
      candidaturas.falhaInesperada = Exception('sem internet');

      await candidatarAoPintor(tester);

      expect(
        find.text(
          'Não foi possível enviar a candidatura agora. Confira sua internet e tente de novo.',
        ),
        findsOneWidget,
      );
      expect(find.text('Candidatar-se'), findsOneWidget);
      expect(
        vagas.vagas['vaga-pintor']?.situacao,
        SituacaoVaga.aguardandoIngresso,
      );
    });
  });
}
