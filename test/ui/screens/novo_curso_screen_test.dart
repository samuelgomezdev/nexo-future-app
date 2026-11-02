import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/domain/models/curso.dart';
import 'package:nexo_future_app/domain/models/oficina.dart';

import '../../apoio/app_de_teste.dart';
import '../../apoio/perfis_falsos.dart';
import '../../apoio/tela_alta.dart';
import '../../apoio/vagas_falsas.dart';

void main() {
  late PerfisFalsos perfis;
  late VagasFalsas vagas;

  const vagaPintor = Vaga(
    id: 'vaga-pintor',
    titulo: 'Pintor(a) naval',
    empresa: 'Estaleiro Foz Azul',
    area: 'Naval',
    cidade: 'Itajaí',
    qualificacao: 'Pintura de cascos.',
    situacao: SituacaoVaga.aberta,
    empresaId: 'uid-marcos',
    posicoes: 3,
  );

  setUp(() {
    perfis = PerfisFalsos();
    vagas = VagasFalsas([vagaPintor]);
    usarTelaAlta();
  });
  tearDown(restaurarTela);

  Future<void> entrarComoOficina(WidgetTester tester, {Alvara? alvara}) async {
    perfis.oficinas[idTeste] = oficinaDeTeste(alvara: alvara);
    await entrarNoApp(tester, perfis: perfis, vagas: vagas);
  }

  Future<void> abrirNovoCurso(WidgetTester tester) async {
    await tester.tap(find.text('Novo curso'));
    await tester.pumpAndSettle();
  }

  Future<void> preencher(WidgetTester tester) async {
    await tester.enterText(
      find.widgetWithText(TextField, 'Nome do curso *'),
      'Pintura naval',
    );
    await escolherOpcao(
      tester,
      'campo-vaga',
      'Pintor(a) naval · Estaleiro Foz Azul',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Carga horária *'),
      '32',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Vagas na turma *'),
      '15',
    );
  }

  CursoOficina cursoDaOficina(String id, SituacaoCurso situacao) =>
      CursoOficina(
        id: id,
        nome: 'Curso $id',
        area: 'Naval',
        cargaHoraria: 32,
        vagasTurma: 15,
        descricao: '',
        vagaId: 'vaga-pintor',
        vagaTitulo: 'Pintor(a) naval',
        empresaId: 'uid-marcos',
        empresa: 'Estaleiro Foz Azul',
        oficinaId: idTeste,
        oficina: 'Oficina Escola Mãos do Porto',
        situacao: situacao,
      );

  group('O1: cursos da oficina', () {
    testWidgets('lista os cursos com a vaga ligada e a situação', (
      tester,
    ) async {
      vagas.cursos['a'] = cursoDaOficina('a', SituacaoCurso.aprovado);
      vagas.cursos['b'] = cursoDaOficina('b', SituacaoCurso.emAnalise);
      vagas.cursos['c'] = cursoDaOficina('c', SituacaoCurso.recusado);

      await entrarComoOficina(tester, alvara: alvaraEmDia);

      expect(find.text('Seus cursos'), findsOneWidget);
      expect(find.text('Curso a'), findsOneWidget);
      expect(
        find.text('Pintor(a) naval · Estaleiro Foz Azul'),
        findsNWidgets(3),
      );
      expect(find.text('Aprovado'), findsOneWidget);
      expect(find.text('Em análise'), findsOneWidget);
      expect(find.text('Recusado'), findsOneWidget);
      expect(find.text('Você ainda não montou cursos.'), findsNothing);
    });

    testWidgets('com alvará em dia, publica o rascunho', (tester) async {
      vagas.cursos['r'] = cursoDaOficina('r', SituacaoCurso.rascunho);
      await entrarComoOficina(tester, alvara: alvaraEmDia);
      expect(find.text('Rascunho'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Publicar'));
      await tester.pumpAndSettle();

      expect(vagas.cursos['r']?.situacao, SituacaoCurso.emAnalise);
      expect(find.text('Em análise'), findsOneWidget);
    });

    testWidgets('sem alvará, o rascunho não tem o botão Publicar', (
      tester,
    ) async {
      vagas.cursos['r'] = cursoDaOficina('r', SituacaoCurso.rascunho);
      await entrarComoOficina(tester);

      expect(find.text('Rascunho'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Publicar'), findsNothing);
    });
  });

  group('O2: cadastro de curso', () {
    testWidgets('mostra os campos do protótipo e as vagas que recebem cursos', (
      tester,
    ) async {
      await entrarComoOficina(tester, alvara: alvaraEmDia);
      await abrirNovoCurso(tester);

      expect(find.text('Campos com * são obrigatórios.'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Nome do curso *'), findsOneWidget);
      expect(find.text('Vaga ligada ao curso *'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Carga horária *'), findsOneWidget);
      expect(
        find.widgetWithText(TextField, 'Vagas na turma *'),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextField, 'Descrição'), findsOneWidget);

      await escolherOpcao(
        tester,
        'campo-vaga',
        'Pintor(a) naval · Estaleiro Foz Azul',
      );
      expect(find.text('Área do curso: Naval'), findsOneWidget);
    });

    testWidgets('os campos obrigatórios vazios ficam apontados', (
      tester,
    ) async {
      await entrarComoOficina(tester, alvara: alvaraEmDia);
      await abrirNovoCurso(tester);

      await tester.tap(find.text('Publicar curso'));
      await tester.pumpAndSettle();

      expect(find.text('Informe o nome do curso.'), findsOneWidget);
      expect(find.text('Escolha a vaga ligada ao curso.'), findsOneWidget);
      expect(find.text('Informe a carga horária.'), findsOneWidget);
      expect(find.text('Informe as vagas na turma.'), findsOneWidget);
      expect(find.text('Corrija 4 campos para continuar.'), findsOneWidget);
      expect(vagas.cursos, isEmpty);
    });

    testWidgets('com alvará em dia, publica o curso para a aprovação', (
      tester,
    ) async {
      await entrarComoOficina(tester, alvara: alvaraEmDia);
      await abrirNovoCurso(tester);
      expect(
        find.text(
          'O recrutador da vaga analisa o curso. Depois de aprovado, ele aparece na vaga para os jovens.',
        ),
        findsOneWidget,
      );

      await preencher(tester);
      await tester.tap(find.text('Publicar curso'));
      await tester.pumpAndSettle();

      final curso = vagas.cursos.values.single;
      expect(curso.nome, 'Pintura naval');
      expect(curso.vagaId, 'vaga-pintor');
      expect(curso.area, 'Naval');
      expect(curso.situacao, SituacaoCurso.emAnalise);

      expect(find.text('Seus cursos'), findsOneWidget);
      expect(find.text('Em análise'), findsOneWidget);
      expect(find.text('Curso enviado para aprovação.'), findsOneWidget);
    });

    testWidgets('sem alvará, mostra o aviso e só salva o rascunho (RN0003)', (
      tester,
    ) async {
      await entrarComoOficina(tester);
      await abrirNovoCurso(tester);

      expect(
        find.text(
          'Para publicar, sua oficina precisa do alvará de ensino em dia (RN0003). O curso fica salvo como rascunho.',
        ),
        findsOneWidget,
      );
      final publicar = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Publicar curso'),
      );
      expect(publicar.onPressed, isNull);

      await preencher(tester);
      await tester.tap(find.text('Salvar rascunho'));
      await tester.pumpAndSettle();

      expect(vagas.cursos.values.single.situacao, SituacaoCurso.rascunho);
      expect(find.text('Rascunho'), findsOneWidget);
      expect(find.text('Rascunho salvo.'), findsOneWidget);
    });

    testWidgets('com o alvará vencido, também não publica', (tester) async {
      await entrarComoOficina(
        tester,
        alvara: Alvara(numero: 'AE-2019-0001', validade: DateTime(2020, 1, 1)),
      );
      await abrirNovoCurso(tester);

      expect(
        find.text(
          'Para publicar, sua oficina precisa do alvará de ensino em dia (RN0003). O curso fica salvo como rascunho.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('sem vagas recebendo cursos, explica o motivo', (tester) async {
      vagas.vagas.clear();
      await entrarComoOficina(tester, alvara: alvaraEmDia);
      await abrirNovoCurso(tester);

      expect(
        find.text(
          'Ainda não há vagas recebendo cursos. Volte quando as empresas publicarem vagas.',
        ),
        findsOneWidget,
      );
    });
  });
}
