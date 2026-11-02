import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/domain/models/curso.dart';

import '../../apoio/app_de_teste.dart';
import '../../apoio/perfis_falsos.dart';
import '../../apoio/tela_alta.dart';
import '../../apoio/vagas_falsas.dart';

void main() {
  late PerfisFalsos perfis;
  late VagasFalsas vagas;

  setUp(() {
    perfis = PerfisFalsos()..empresas[idTeste] = empresaDeTeste();
    vagas = VagasFalsas();
    usarTelaAlta();
  });
  tearDown(restaurarTela);

  CursoOficina proposto(String id, String vagaId, {String? nome}) =>
      CursoOficina(
        id: id,
        nome: nome ?? 'Curso $id',
        area: 'Naval',
        cargaHoraria: 32,
        vagasTurma: 15,
        descricao: '',
        vagaId: vagaId,
        vagaTitulo: 'Pintor(a) naval',
        empresaId: idTeste,
        empresa: 'Estaleiro Foz Azul',
        oficinaId: 'uid-rita',
        oficina: 'Oficina Escola Mãos do Porto',
        situacao: SituacaoCurso.emAnalise,
      );

  Vaga vagaDaEmpresa(String id, String titulo, {SituacaoVaga? situacao}) =>
      Vaga(
        id: id,
        titulo: titulo,
        empresa: 'Estaleiro Foz Azul',
        area: 'Naval',
        cidade: 'Itajaí',
        qualificacao: 'Pintura de cascos.',
        situacao: situacao ?? SituacaoVaga.aberta,
        empresaId: idTeste,
        posicoes: 3,
      );

  group('E1: painel da empresa', () {
    testWidgets('mostra as vagas da empresa e os cursos para aprovar', (
      tester,
    ) async {
      vagas.vagas['v1'] = vagaDaEmpresa('v1', 'Pintor(a) naval');
      vagas.vagas['v2'] = vagaDaEmpresa(
        'v2',
        'Laminador(a)',
        situacao: SituacaoVaga.aguardandoIngresso,
      );
      vagas.cursos['c1'] = proposto('c1', 'v1', nome: 'Pintura naval');

      await entrarNoApp(tester, perfis: perfis, vagas: vagas);

      expect(find.text('Suas vagas'), findsOneWidget);
      expect(find.text('Pintor(a) naval'), findsOneWidget);
      expect(find.text('Laminador(a)'), findsOneWidget);
      expect(find.byKey(const Key('total-vagas-abertas')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('total-vagas-abertas')),
          matching: find.text('2'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('total-cursos-para-aprovar')),
          matching: find.text('1'),
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          '1 curso aguarda sua aprovação. Sem curso aprovado, a vaga não recebe candidaturas.',
        ),
        findsOneWidget,
      );
      expect(find.text('Pintura naval'), findsOneWidget);
      expect(find.text('Você ainda não publicou vagas.'), findsNothing);
    });

    testWidgets('sem vagas, convida a publicar a primeira', (tester) async {
      await entrarNoApp(tester, perfis: perfis, vagas: vagas);

      expect(find.text('Você ainda não publicou vagas.'), findsOneWidget);
      expect(find.text('Nova vaga'), findsOneWidget);
    });
  });

  group('E2: cadastro de vaga', () {
    Future<void> abrirNovaVaga(WidgetTester tester) async {
      await entrarNoApp(tester, perfis: perfis, vagas: vagas);
      await tester.tap(find.text('Nova vaga'));
      await tester.pumpAndSettle();
    }

    testWidgets('mostra os campos do protótipo, com área e cidade da empresa', (
      tester,
    ) async {
      await abrirNovaVaga(tester);

      expect(find.text('Campos com * são obrigatórios.'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Cargo *'), findsOneWidget);
      expect(find.text('Área *'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Posições *'), findsOneWidget);
      expect(find.text('Cidade *'), findsOneWidget);
      expect(
        find.widgetWithText(TextField, 'Qualificação exigida *'),
        findsOneWidget,
      );
      // Área e cidade já vêm com o setor e a cidade da empresa (RNF0005).
      expect(find.text('Naval'), findsOneWidget);
      expect(find.text('Itajaí'), findsOneWidget);
      expect(find.text('0 de 5'), findsOneWidget);
      expect(
        find.text(
          'Até 5 cursos (RN0006). As oficinas enviam cursos e você aprova.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'A vaga aparece na pesquisa ao publicar e passa a receber candidaturas depois que você aprovar um curso.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('no tamanho de um celular, os campos cabem na largura', (
      tester,
    ) async {
      usarTelaDeCelular();
      await abrirNovaVaga(tester);

      await escolherOpcao(tester, 'campo-area', 'Turismo e Hotelaria');

      expect(tester.takeException(), isNull);
      expect(find.text('Turismo e Hotelaria'), findsOneWidget);
    });

    testWidgets('os campos obrigatórios vazios ficam apontados', (
      tester,
    ) async {
      await abrirNovaVaga(tester);

      await tester.tap(find.text('Publicar vaga'));
      await tester.pumpAndSettle();

      expect(find.text('Informe o cargo da vaga.'), findsOneWidget);
      expect(
        find.text('Informe quantas pessoas a vaga contrata.'),
        findsOneWidget,
      );
      expect(find.text('Informe a qualificação exigida.'), findsOneWidget);
      expect(find.text('Corrija 3 campos para continuar.'), findsOneWidget);
      expect(vagas.vagas, isEmpty);
    });

    testWidgets('corrigir um campo tira o erro dele na hora', (tester) async {
      await abrirNovaVaga(tester);
      await tester.tap(find.text('Publicar vaga'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Cargo *'),
        'Pintor(a) naval',
      );
      await tester.pumpAndSettle();

      expect(find.text('Informe o cargo da vaga.'), findsNothing);
      expect(find.text('Corrija 2 campos para continuar.'), findsOneWidget);
    });

    testWidgets('publica a vaga, que volta ao painel como aberta', (
      tester,
    ) async {
      await abrirNovaVaga(tester);

      await tester.enterText(
        find.widgetWithText(TextField, 'Cargo *'),
        'Soldador(a)',
      );
      await escolherOpcao(tester, 'campo-area', 'Metalurgia');
      await tester.enterText(find.widgetWithText(TextField, 'Posições *'), '2');
      await escolherOpcao(tester, 'campo-cidade', 'Navegantes');
      await tester.enterText(
        find.widgetWithText(TextField, 'Qualificação exigida *'),
        'Solda MIG/MAG.',
      );
      await tester.tap(find.text('Publicar vaga'));
      await tester.pumpAndSettle();

      final publicada = vagas.vagas.values.single;
      expect(publicada.titulo, 'Soldador(a)');
      expect(publicada.area, 'Metalurgia');
      expect(publicada.cidade, 'Navegantes');
      expect(publicada.posicoes, 2);
      expect(publicada.situacao, SituacaoVaga.aberta);
      expect(publicada.empresaId, idTeste);

      expect(find.text('Suas vagas'), findsOneWidget);
      expect(find.text('Soldador(a)'), findsOneWidget);
      expect(find.text('Aguardando cursos'), findsOneWidget);
      expect(find.text('Vaga publicada.'), findsOneWidget);
    });

    testWidgets('sem internet, avisa e mantém o formulário', (tester) async {
      await abrirNovaVaga(tester);
      await tester.enterText(
        find.widgetWithText(TextField, 'Cargo *'),
        'Soldador(a)',
      );
      await tester.enterText(find.widgetWithText(TextField, 'Posições *'), '2');
      await tester.enterText(
        find.widgetWithText(TextField, 'Qualificação exigida *'),
        'Solda MIG/MAG.',
      );
      vagas.falhaInesperada = Exception('sem internet');

      await tester.tap(find.text('Publicar vaga'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Não foi possível salvar agora. Confira sua internet e tente de novo.',
        ),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextField, 'Cargo *'), findsOneWidget);
    });
  });
}
