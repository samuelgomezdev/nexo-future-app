import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/domain/models/curso.dart';
import 'package:nexo_future_app/ui/app.dart';

import '../../apoio/autenticacao_falsa.dart';
import '../../apoio/perfis_falsos.dart';
import '../../apoio/tela_alta.dart';
import '../../apoio/vagas_falsas.dart';

void main() {
  // RF0004 e RF0006: a vaga publicada pela empresa entra na pesquisa, também
  // para o visitante sem conta (RN0007).
  group('Vaga nova na pesquisa', () {
    late VagasFalsas vagas;

    const nova = Vaga(
      id: 'nova',
      titulo: 'Pintor(a) naval',
      empresa: 'Estaleiro Foz Azul',
      area: 'Naval',
      cidade: 'Itajaí',
      qualificacao: 'Preparo de superfície e pintura de cascos.',
      situacao: SituacaoVaga.aberta,
      empresaId: 'uid-marcos',
      posicoes: 3,
    );

    setUp(() {
      vagas = VagasFalsas();
      usarTelaAlta();
    });
    tearDown(restaurarTela);

    Future<void> abrirApp(WidgetTester tester) async {
      await tester.pumpWidget(
        NexoFutureApp(
          autenticacao: AutenticacaoFalsa(),
          perfis: PerfisFalsos(),
          vagas: vagas,
        ),
      );
      await tester.pumpAndSettle();
    }

    String primeiraDaLista(WidgetTester tester) {
      final primeiro = tester.widget<ListTile>(find.byType(ListTile).first);
      return (primeiro.title! as Text).data!;
    }

    testWidgets('o visitante vê a vaga nova no topo da lista', (tester) async {
      vagas.vagas['nova'] = nova;

      await abrirApp(tester);

      expect(primeiraDaLista(tester), 'Pintor(a) naval');
      expect(find.text('Estaleiro Foz Azul · Itajaí'), findsWidgets);
    });

    testWidgets('a pesquisa por texto encontra a vaga nova', (tester) async {
      vagas.vagas['nova'] = nova;
      await abrirApp(tester);

      await tester.enterText(find.byType(TextField), 'pintor');
      await tester.pumpAndSettle();

      expect(primeiraDaLista(tester), 'Pintor(a) naval');
    });

    testWidgets('sem curso aprovado, a vaga nova ainda não recebe '
        'candidaturas (RF0007)', (tester) async {
      vagas.vagas['nova'] = nova;
      await abrirApp(tester);

      await tester.tap(find.text('Pintor(a) naval').first);
      await tester.pumpAndSettle();

      expect(
        find.text('O recrutador ainda não aprovou cursos para esta vaga.'),
        findsOneWidget,
      );
      expect(find.text('Vaga indisponível no momento'), findsOneWidget);
    });

    testWidgets('com o curso aprovado, mostra o curso e pede login para se '
        'candidatar', (tester) async {
      vagas.vagas['nova'] = nova.copiar(
        situacao: SituacaoVaga.aguardandoIngresso,
        cursos: const [
          Curso(
            id: 'curso-pintura',
            nome: 'Pintura naval',
            oficina: 'Oficina Escola Mãos do Porto',
            cargaHoraria: 32,
          ),
        ],
      );
      await abrirApp(tester);

      await tester.tap(find.text('Pintor(a) naval').first);
      await tester.pumpAndSettle();
      expect(find.text('Pintura naval'), findsOneWidget);

      await tester.tap(find.text('Candidatar-se'));
      await tester.pumpAndSettle();

      expect(
        find.text('Entre ou crie sua conta para se candidatar.'),
        findsOneWidget,
      );
    });

    testWidgets('puxar a lista para baixo traz a vaga publicada depois', (
      tester,
    ) async {
      await abrirApp(tester);
      expect(find.text('Pintor(a) naval'), findsNothing);

      vagas.vagas['nova'] = nova;
      await tester.drag(find.byType(ListTile).first, const Offset(0, 1200));
      await tester.pumpAndSettle();

      expect(primeiraDaLista(tester), 'Pintor(a) naval');
    });

    testWidgets('sem internet, avisa e continua com as vagas que já tinha', (
      tester,
    ) async {
      vagas.falhaInesperada = Exception('sem internet');

      await abrirApp(tester);

      expect(
        find.text(
          'Não foi possível buscar as vagas mais novas. Puxe a lista para tentar de novo.',
        ),
        findsOneWidget,
      );
      expect(find.text('Laminador'), findsWidgets);
    });
  });
}
