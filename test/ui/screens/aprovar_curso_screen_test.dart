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

  const vagaPintor = Vaga(
    id: 'vaga-pintor',
    titulo: 'Pintor(a) naval',
    empresa: 'Estaleiro Foz Azul',
    area: 'Naval',
    cidade: 'Itajaí',
    qualificacao: 'Pintura de cascos.',
    situacao: SituacaoVaga.aberta,
    empresaId: idTeste,
    posicoes: 3,
  );

  const pintura = CursoOficina(
    id: 'curso-pintura',
    nome: 'Pintura naval',
    area: 'Naval',
    cargaHoraria: 32,
    vagasTurma: 15,
    descricao: 'Preparo de superfície, primer e acabamento em cascos.',
    vagaId: 'vaga-pintor',
    vagaTitulo: 'Pintor(a) naval',
    empresaId: idTeste,
    empresa: 'Estaleiro Foz Azul',
    oficinaId: 'uid-rita',
    oficina: 'Oficina Escola Mãos do Porto',
    situacao: SituacaoCurso.emAnalise,
  );

  setUp(() {
    perfis = PerfisFalsos()..empresas[idTeste] = empresaDeTeste();
    vagas = VagasFalsas([vagaPintor]);
    vagas.cursos[pintura.id] = pintura;
    usarTelaAlta();
  });
  tearDown(restaurarTela);

  Future<void> abrirAprovacao(WidgetTester tester) async {
    await entrarNoApp(tester, perfis: perfis, vagas: vagas);
    await tester.tap(find.text('Pintura naval'));
    await tester.pumpAndSettle();
  }

  group('E3: aprovação do curso pelo recrutador', () {
    testWidgets('mostra a vaga, a oficina e os dados do curso', (tester) async {
      await abrirAprovacao(tester);

      expect(find.text('Aprovar curso'), findsWidgets);
      expect(
        find.text('Para a vaga: Pintor(a) naval · 3 posições'),
        findsOneWidget,
      );
      expect(find.text('Pintura naval'), findsOneWidget);
      expect(find.text('Oficina Escola Mãos do Porto'), findsOneWidget);
      expect(find.text('32 horas'), findsOneWidget);
      expect(find.text('15 vagas'), findsOneWidget);
      expect(find.text('O que o curso ensina'), findsOneWidget);
      expect(
        find.text('Preparo de superfície, primer e acabamento em cascos.'),
        findsOneWidget,
      );
      expect(find.text('0 de 5 cursos vinculados'), findsOneWidget);
      expect(
        find.text('Ao aprovar, a vaga passa a aceitar candidaturas (RF0007).'),
        findsOneWidget,
      );
    });

    testWidgets('aprovar vincula o curso e a vaga passa a aceitar '
        'candidaturas', (tester) async {
      await abrirAprovacao(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Aprovar curso'));
      await tester.pumpAndSettle();

      final vaga = vagas.vagas['vaga-pintor']!;
      expect(vaga.situacao, SituacaoVaga.aguardandoIngresso);
      expect(vaga.cursos.single.nome, 'Pintura naval');
      expect(vagas.cursos['curso-pintura']?.situacao, SituacaoCurso.aprovado);

      expect(find.text('Suas vagas'), findsOneWidget);
      expect(find.text('Aceitando candidaturas'), findsOneWidget);
      expect(
        find.text('Curso aprovado. A vaga já aceita candidaturas.'),
        findsOneWidget,
      );
    });

    testWidgets('recusar deixa a vaga como estava', (tester) async {
      await abrirAprovacao(tester);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Recusar'));
      await tester.pumpAndSettle();

      expect(vagas.cursos['curso-pintura']?.situacao, SituacaoCurso.recusado);
      expect(vagas.vagas['vaga-pintor']?.situacao, SituacaoVaga.aberta);
      expect(find.text('Suas vagas'), findsOneWidget);
      expect(find.text('Aguardando cursos'), findsOneWidget);
      expect(find.text('Curso recusado.'), findsOneWidget);
    });

    testWidgets('com 5 cursos na vaga, explica por que não aprova (RN0006)', (
      tester,
    ) async {
      vagas.vagas['vaga-pintor'] = vagaPintor.copiar(
        situacao: SituacaoVaga.aguardandoIngresso,
        cursos: [
          for (var i = 1; i <= 5; i++)
            Curso(id: 'v$i', nome: 'Vinculado $i', oficina: 'Oficina'),
        ],
      );
      await abrirAprovacao(tester);
      expect(find.text('5 de 5 cursos vinculados'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Aprovar curso'));
      await tester.pumpAndSettle();

      expect(
        find.text('Esta vaga já tem 5 cursos vinculados.'),
        findsOneWidget,
      );
      expect(vagas.cursos['curso-pintura']?.situacao, SituacaoCurso.emAnalise);
    });
  });
}
