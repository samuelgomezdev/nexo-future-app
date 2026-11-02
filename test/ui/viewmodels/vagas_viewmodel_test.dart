import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/data/vaga_repository.dart';
import 'package:nexo_future_app/domain/models/vaga.dart';
import 'package:nexo_future_app/ui/viewmodels/vagas_viewmodel.dart';

import '../../apoio/vagas_falsas.dart';

Vaga vaga(int numero, String titulo, String area) => Vaga(
  id: 'vaga-$numero',
  titulo: titulo,
  empresa: 'Estaleiro Foz Azul',
  area: area,
  cidade: 'Itajaí',
  qualificacao: 'Ensino fundamental completo',
  situacao: SituacaoVaga.aguardandoIngresso,
);

void main() {
  group('VagasViewModel (F1: lista e pesquisa de vagas)', () {
    late VagasViewModel viewModel;
    late int avisos;

    setUp(() {
      final vagas = [
        for (var i = 1; i <= 18; i++) vaga(i, 'Laminador $i', 'Naval'),
        vaga(19, 'Soldador', 'Metalurgia'),
        vaga(20, 'Mecânico Diesel', 'Logística'),
      ];
      viewModel = VagasViewModel(VagaRepository(vagas));
      avisos = 0;
      viewModel.addListener(() => avisos++);
    });

    test('começa com a primeira página de 15 vagas', () {
      expect(viewModel.vagas, hasLength(15));
      expect(viewModel.temMais, isTrue);
    });

    test('carregar mais acrescenta a próxima página', () {
      viewModel.carregarMais();

      expect(viewModel.vagas, hasLength(20));
      expect(viewModel.vagas.last.id, 'vaga-20');
      expect(viewModel.temMais, isFalse);
      expect(avisos, 1);
    });

    test('sem mais páginas, carregar mais não muda nada', () {
      viewModel.carregarMais();
      viewModel.carregarMais();

      expect(viewModel.vagas, hasLength(20));
      expect(avisos, 1);
    });

    test('pesquisar por texto volta para a primeira página filtrada', () {
      viewModel.carregarMais();

      viewModel.pesquisar('solda');

      expect(viewModel.vagas.map((v) => v.titulo), ['Soldador']);
      expect(viewModel.texto, 'solda');
      expect(viewModel.temMais, isFalse);
    });

    test('filtrar por área mostra só as vagas da área', () {
      viewModel.filtrarArea('Logística');

      expect(viewModel.vagas.map((v) => v.titulo), ['Mecânico Diesel']);
      expect(viewModel.areaSelecionada, 'Logística');
    });

    test('limpar a área volta a mostrar todas as áreas', () {
      viewModel.filtrarArea('Logística');

      viewModel.filtrarArea(null);

      expect(viewModel.vagas, hasLength(15));
      expect(viewModel.areaSelecionada, isNull);
    });

    test('oferece as áreas para o filtro', () {
      expect(viewModel.areas, ['Logística', 'Metalurgia', 'Naval']);
    });
  });

  group('VagasViewModel com as vagas do Firestore', () {
    test('atualizar traz as vagas publicadas para o começo da lista', () async {
      final fonte = VagasFalsas([vaga(99, 'Pintor(a) naval', 'Naval')]);
      final viewModel = VagasViewModel(
        VagaRepository([vaga(1, 'Laminador', 'Naval')], fonte: fonte),
      );
      expect(viewModel.vagas.map((v) => v.id), ['vaga-1']);

      await viewModel.atualizar();

      expect(viewModel.vagas.map((v) => v.id), ['vaga-99', 'vaga-1']);
      expect(viewModel.erroAtualizacao, isNull);
    });

    test('atualizar mantém o texto e a área da pesquisa', () async {
      final fonte = VagasFalsas([vaga(99, 'Soldador(a)', 'Metalurgia')]);
      final viewModel = VagasViewModel(
        VagaRepository([vaga(1, 'Soldador', 'Naval')], fonte: fonte),
      )..filtrarArea('Metalurgia');

      await viewModel.atualizar();

      expect(viewModel.vagas.map((v) => v.id), ['vaga-99']);
    });

    test('sem internet, avisa e mantém as vagas', () async {
      final fonte = VagasFalsas()..falhaInesperada = Exception('sem internet');
      final viewModel = VagasViewModel(
        VagaRepository([vaga(1, 'Laminador', 'Naval')], fonte: fonte),
      );

      await viewModel.atualizar();

      expect(viewModel.vagas, hasLength(1));
      expect(
        viewModel.erroAtualizacao,
        'Não foi possível buscar as vagas mais novas. Puxe a lista para tentar de novo.',
      );
    });
  });
}
