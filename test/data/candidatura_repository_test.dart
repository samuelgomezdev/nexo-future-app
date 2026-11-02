import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/data/candidatura_repository.dart';
import 'package:nexo_future_app/data/candidaturas_em_memoria.dart';
import 'package:nexo_future_app/data/vagas_em_memoria.dart';
import 'package:nexo_future_app/domain/erros.dart';
import 'package:nexo_future_app/domain/models/vaga.dart';

Vaga vaga(
  String id, {
  SituacaoVaga situacao = SituacaoVaga.aguardandoIngresso,
  String empresaId = '',
  int posicoes = 1,
  int candidaturas = 0,
}) => Vaga(
  id: id,
  titulo: 'Soldador',
  empresa: 'MetalSul Usinagem',
  area: 'Metalurgia',
  cidade: 'Itajaí',
  qualificacao: 'Ensino fundamental completo',
  situacao: situacao,
  empresaId: empresaId,
  posicoes: posicoes,
  candidaturas: candidaturas,
);

/// Simula a queda da conexão na hora de gravar.
class CandidaturasInstaveis extends CandidaturasEmMemoria {
  bool semInternet = false;

  @override
  Future<void> salvar(
    String jovemId,
    List<String> vagas, {
    String? entrou,
    String? saiu,
  }) async {
    if (semInternet) throw Exception('sem internet');
    await super.salvar(jovemId, vagas, entrou: entrou, saiu: saiu);
  }
}

void main() {
  group('Repositório de candidaturas do aluno', () {
    late CandidaturaRepository repositorio;

    setUp(() {
      repositorio = CandidaturaRepository(alunoId: 'jovem-demo');
    });

    test('começa sem candidaturas', () {
      expect(repositorio.ativas, isEmpty);
    });

    test('registra a candidatura numa vaga aguardando ingresso', () async {
      await repositorio.candidatar(vaga('vaga-1'));

      expect(repositorio.ativas.single.vagaId, 'vaga-1');
      expect(repositorio.jaCandidatou('vaga-1'), isTrue);
      expect(repositorio.jaCandidatou('vaga-2'), isFalse);
    });

    test('recusa vaga que não está aguardando ingresso (RF0007)', () async {
      await expectLater(
        repositorio.candidatar(vaga('vaga-1', situacao: SituacaoVaga.lotada)),
        throwsA(isA<VagaNaoDisponivel>()),
      );
      expect(repositorio.ativas, isEmpty);
    });

    test('recusa a 6ª candidatura (RN0005)', () async {
      for (var i = 1; i <= 5; i++) {
        await repositorio.candidatar(vaga('vaga-$i'));
      }

      await expectLater(
        repositorio.candidatar(vaga('vaga-6')),
        throwsA(isA<LimiteCandidaturasAtingido>()),
      );
    });

    test('desistir remove a candidatura', () async {
      await repositorio.candidatar(vaga('vaga-1'));

      await repositorio.desistir('vaga-1');

      expect(repositorio.ativas, isEmpty);
      expect(repositorio.jaCandidatou('vaga-1'), isFalse);
    });
  });

  group('Candidaturas guardadas por jovem', () {
    late VagasEmMemoria vagas;
    late CandidaturasEmMemoria guardadas;

    setUp(() {
      vagas = VagasEmMemoria([
        vaga('publicada', empresaId: 'uid-marcos', posicoes: 2),
      ]);
      guardadas = CandidaturasEmMemoria(vagas);
    });

    CandidaturaRepository repositorioDe(String jovemId) =>
        CandidaturaRepository(alunoId: jovemId, fonte: guardadas);

    test(
      'a candidatura fica salva e volta quando o jovem entra de novo',
      () async {
        await repositorioDe('uid-carla').candidatar(vaga('vaga-01'));

        final outroAparelho = CandidaturaRepository(
          alunoId: 'jovem-demo',
          fonte: guardadas,
        );
        await outroAparelho.entrar('uid-carla');

        expect(outroAparelho.jaCandidatou('vaga-01'), isTrue);
        expect(await guardadas.carregar('uid-carla'), ['vaga-01']);
      },
    );

    test('cada jovem tem as próprias candidaturas', () async {
      await repositorioDe('uid-carla').candidatar(vaga('vaga-01'));

      final bruno = repositorioDe('uid-bruno');
      await bruno.entrar('uid-bruno');

      expect(bruno.ativas, isEmpty);
    });

    test(
      'o limite de 5 vale também para o que já estava salvo (RN0005)',
      () async {
        final carla = repositorioDe('uid-carla');
        for (var i = 1; i <= 5; i++) {
          await carla.candidatar(vaga('vaga-$i'));
        }
        final deNovo = repositorioDe('uid-carla');
        await deNovo.entrar('uid-carla');

        await expectLater(
          deNovo.candidatar(vaga('vaga-6')),
          throwsA(isA<LimiteCandidaturasAtingido>()),
        );
      },
    );

    test('a candidatura conta na vaga publicada, que lota ao completar as '
        'posições', () async {
      final carla = repositorioDe('uid-carla');
      final bruno = repositorioDe('uid-bruno');

      await carla.candidatar(vaga('publicada', empresaId: 'uid-marcos'));
      expect(vagas.vagas['publicada']?.candidaturas, 1);
      expect(
        vagas.vagas['publicada']?.situacao,
        SituacaoVaga.aguardandoIngresso,
      );

      await bruno.candidatar(vaga('publicada', empresaId: 'uid-marcos'));
      expect(vagas.vagas['publicada']?.candidaturas, 2);
      expect(vagas.vagas['publicada']?.situacao, SituacaoVaga.lotada);
    });

    test(
      'a vaga que lotou enquanto o jovem olhava recusa a candidatura',
      () async {
        vagas.vagas['publicada'] = vaga(
          'publicada',
          empresaId: 'uid-marcos',
          posicoes: 2,
          candidaturas: 2,
          situacao: SituacaoVaga.lotada,
        );
        final carla = repositorioDe('uid-carla');

        // A tela ainda mostra a vaga como aceitando candidaturas.
        await expectLater(
          carla.candidatar(vaga('publicada', empresaId: 'uid-marcos')),
          throwsA(isA<VagaNaoDisponivel>()),
        );
        expect(carla.ativas, isEmpty);
        expect(await guardadas.carregar('uid-carla'), isEmpty);
      },
    );

    test('desistir desconta a candidatura e a vaga volta a aceitar', () async {
      final carla = repositorioDe('uid-carla');
      await carla.candidatar(vaga('publicada', empresaId: 'uid-marcos'));
      await repositorioDe('uid-bruno')
          .candidatar(vaga('publicada', empresaId: 'uid-marcos'));
      expect(vagas.vagas['publicada']?.situacao, SituacaoVaga.lotada);

      await carla.desistir('publicada');

      expect(vagas.vagas['publicada']?.candidaturas, 1);
      expect(
        vagas.vagas['publicada']?.situacao,
        SituacaoVaga.aguardandoIngresso,
      );
      expect(await guardadas.carregar('uid-carla'), isEmpty);
    });

    test('sem internet, a candidatura não fica pela metade', () async {
      final instaveis = CandidaturasInstaveis()..semInternet = true;
      final carla = CandidaturaRepository(
        alunoId: 'uid-carla',
        fonte: instaveis,
      );

      await expectLater(carla.candidatar(vaga('vaga-01')), throwsException);
      expect(carla.ativas, isEmpty);
    });

    test('sem internet, a desistência é desfeita', () async {
      final instaveis = CandidaturasInstaveis();
      final carla = CandidaturaRepository(
        alunoId: 'uid-carla',
        fonte: instaveis,
      );
      await carla.candidatar(vaga('vaga-01'));
      instaveis.semInternet = true;

      await expectLater(carla.desistir('vaga-01'), throwsException);
      expect(carla.jaCandidatou('vaga-01'), isTrue);
    });

    test('sair volta a não ter candidaturas no aparelho', () async {
      final carla = repositorioDe('uid-carla');
      await carla.candidatar(vaga('vaga-01'));

      carla.sair();

      expect(carla.ativas, isEmpty);
    });
  });
}
