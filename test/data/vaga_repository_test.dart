import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/data/vaga_repository.dart';
import 'package:nexo_future_app/domain/models/vaga.dart';

import '../apoio/vagas_falsas.dart';

Vaga vaga(String id, String titulo, {String area = 'Naval'}) => Vaga(
  id: id,
  titulo: titulo,
  empresa: 'Estaleiro Foz Azul',
  area: area,
  cidade: 'Itajaí',
  qualificacao: 'Ensino fundamental completo',
  situacao: SituacaoVaga.aguardandoIngresso,
);

void main() {
  group('RNF0002: pesquisa em páginas de 15 vagas', () {
    final vinteVagas = [
      for (var i = 1; i <= 20; i++) vaga('vaga-$i', 'Laminador $i'),
    ];

    test('a página tem 15 vagas', () {
      expect(tamanhoPagina, 15);
    });

    test('página 1 traz 15 vagas e a página 2 traz o restante', () {
      final repositorio = VagaRepository(vinteVagas);

      final pagina1 = repositorio.pesquisar(pagina: 1);
      final pagina2 = repositorio.pesquisar(pagina: 2);

      expect(pagina1, hasLength(15));
      expect(pagina1.first.id, 'vaga-1');
      expect(pagina2, hasLength(5));
      expect(pagina2.first.id, 'vaga-16');
    });

    test('página depois da última vem vazia', () {
      final repositorio = VagaRepository(vinteVagas);

      expect(repositorio.pesquisar(pagina: 3), isEmpty);
    });
  });

  group('Filtro da pesquisa de vagas', () {
    final repositorio = VagaRepository([
      vaga('v1', 'Soldador', area: 'Metalurgia'),
      vaga('v2', 'Mecânico Diesel', area: 'Logística'),
      vaga('v3', 'Pintor Naval', area: 'Naval'),
      vaga('v4', 'Inspetor de Qualidade', area: 'Metalurgia'),
    ]);

    List<String> ids(List<Vaga> vagas) => vagas.map((v) => v.id).toList();

    test('texto ignora maiúsculas: "solda" encontra "Soldador"', () {
      expect(ids(repositorio.pesquisar(texto: 'solda')), ['v1']);
      expect(ids(repositorio.pesquisar(texto: 'SOLDA')), ['v1']);
    });

    test('texto ignora acentos: "mecanico" encontra "Mecânico Diesel"', () {
      expect(ids(repositorio.pesquisar(texto: 'mecanico')), ['v2']);
    });

    test('filtra por área', () {
      expect(ids(repositorio.pesquisar(area: 'Metalurgia')), ['v1', 'v4']);
    });

    test('combina texto e área', () {
      expect(
        ids(repositorio.pesquisar(texto: 'inspetor', area: 'Metalurgia')),
        ['v4'],
      );
      expect(repositorio.pesquisar(texto: 'soldador', area: 'Naval'), isEmpty);
    });

    test('sem filtro traz todas as vagas', () {
      expect(repositorio.pesquisar(), hasLength(4));
    });
  });

  group('Consultas auxiliares do repositório de vagas', () {
    final repositorio = VagaRepository([
      vaga('v1', 'Soldador', area: 'Metalurgia'),
      vaga('v2', 'Mecânico Diesel', area: 'Logística'),
      vaga('v3', 'Inspetor de Qualidade', area: 'Metalurgia'),
    ]);

    test('busca a vaga pelo id', () {
      expect(repositorio.buscarPorId('v2')?.titulo, 'Mecânico Diesel');
    });

    test('id inexistente devolve nulo', () {
      expect(repositorio.buscarPorId('nao-existe'), isNull);
    });

    test('lista as áreas sem repetir, em ordem alfabética', () {
      expect(repositorio.areas, ['Logística', 'Metalurgia']);
    });
  });

  group('Vagas publicadas no Firestore entram na pesquisa', () {
    final doSeed = [vaga('vaga-01', 'Laminador'), vaga('vaga-02', 'Soldador')];

    test('antes de atualizar, a pesquisa mostra só as vagas fictícias', () {
      final fonte = VagasFalsas([vaga('nova', 'Pintor(a) naval')]);
      final repositorio = VagaRepository(doSeed, fonte: fonte);

      expect(repositorio.pesquisar().map((v) => v.id), ['vaga-01', 'vaga-02']);
    });

    test('a vaga nova aparece primeiro, antes das fictícias', () async {
      final fonte = VagasFalsas([vaga('nova', 'Pintor(a) naval')]);
      final repositorio = VagaRepository(doSeed, fonte: fonte);

      await repositorio.atualizar();

      expect(repositorio.pesquisar().map((v) => v.id), [
        'nova',
        'vaga-01',
        'vaga-02',
      ]);
      expect(repositorio.buscarPorId('nova')?.titulo, 'Pintor(a) naval');
    });

    test('a vaga nova entra no filtro por texto e por área', () async {
      final fonte = VagasFalsas([
        vaga('nova', 'Pintor(a) naval'),
        vaga('outra', 'Cozinheiro', area: 'Alimentos'),
      ]);
      final repositorio = VagaRepository(doSeed, fonte: fonte);
      await repositorio.atualizar();

      expect(repositorio.pesquisar(texto: 'pintor').map((v) => v.id), ['nova']);
      expect(repositorio.pesquisar(area: 'Alimentos').map((v) => v.id), [
        'outra',
      ]);
      expect(repositorio.areas, ['Alimentos', 'Naval']);
    });

    test('continua em páginas de 15 com as vagas novas', () async {
      final fonte = VagasFalsas([
        for (var i = 1; i <= 10; i++) vaga('nova-$i', 'Pintor $i'),
      ]);
      final repositorio = VagaRepository([
        for (var i = 1; i <= 10; i++) vaga('seed-$i', 'Laminador $i'),
      ], fonte: fonte);
      await repositorio.atualizar();

      expect(repositorio.pesquisar(pagina: 1), hasLength(15));
      expect(repositorio.pesquisar(pagina: 2), hasLength(5));
    });

    test('atualizar de novo troca as vagas do Firestore sem repetir', () async {
      final fonte = VagasFalsas([vaga('nova', 'Pintor(a) naval')]);
      final repositorio = VagaRepository(doSeed, fonte: fonte);
      await repositorio.atualizar();

      fonte.vagas['nova'] = vaga('nova', 'Pintor(a) naval sênior');
      await repositorio.atualizar();

      expect(repositorio.pesquisar(), hasLength(3));
      expect(repositorio.buscarPorId('nova')?.titulo, 'Pintor(a) naval sênior');
    });

    test('sem internet, a falha chega a quem pediu e as vagas ficam', () async {
      final fonte = VagasFalsas([vaga('nova', 'Pintor(a) naval')]);
      final repositorio = VagaRepository(doSeed, fonte: fonte);
      await repositorio.atualizar();

      fonte.falhaInesperada = Exception('sem internet');

      await expectLater(repositorio.atualizar(), throwsException);
      expect(repositorio.pesquisar(), hasLength(3));
    });

    test('sem fonte, atualizar não muda nada', () async {
      final repositorio = VagaRepository(doSeed);

      await repositorio.atualizar();

      expect(repositorio.pesquisar(), hasLength(2));
    });
  });
}
