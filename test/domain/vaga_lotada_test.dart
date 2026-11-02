import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/domain/erros.dart';
import 'package:nexo_future_app/domain/models/vaga.dart';
import 'package:nexo_future_app/domain/regras/situacao_vaga.dart';

void main() {
  Vaga vaga({
    int posicoes = 3,
    int candidaturas = 0,
    SituacaoVaga situacao = SituacaoVaga.aguardandoIngresso,
  }) => Vaga(
    id: 'vaga-pintor',
    titulo: 'Pintor(a) naval',
    empresa: 'Estaleiro Foz Azul',
    area: 'Naval',
    cidade: 'Itajaí',
    qualificacao: 'Pintura de cascos.',
    situacao: situacao,
    empresaId: 'uid-marcos',
    posicoes: posicoes,
    candidaturas: candidaturas,
  );

  group('A vaga lota quando as candidaturas preenchem as posições', () {
    test('a vaga começa sem candidaturas', () {
      expect(vaga().candidaturas, 0);
    });

    test('cada candidatura conta uma posição', () {
      final depois = registrarCandidatura(vaga());

      expect(depois.candidaturas, 1);
      expect(depois.situacao, SituacaoVaga.aguardandoIngresso);
    });

    test('a candidatura que completa as posições deixa a vaga lotada', () {
      final depois = registrarCandidatura(vaga(candidaturas: 2));

      expect(depois.candidaturas, 3);
      expect(depois.situacao, SituacaoVaga.lotada);
    });

    test('vaga de uma posição lota na primeira candidatura', () {
      expect(
        registrarCandidatura(vaga(posicoes: 1)).situacao,
        SituacaoVaga.lotada,
      );
    });

    test('vaga lotada ou ainda sem curso não recebe candidatura (RF0007)', () {
      expect(
        () => registrarCandidatura(
          vaga(candidaturas: 3, situacao: SituacaoVaga.lotada),
        ),
        throwsA(isA<VagaNaoDisponivel>()),
      );
      expect(
        () => registrarCandidatura(vaga(situacao: SituacaoVaga.aberta)),
        throwsA(isA<VagaNaoDisponivel>()),
      );
    });

    test(
      'quando alguém desiste, a vaga lotada volta a aceitar candidaturas',
      () {
        final depois = liberarCandidatura(
          vaga(candidaturas: 3, situacao: SituacaoVaga.lotada),
        );

        expect(depois.candidaturas, 2);
        expect(depois.situacao, SituacaoVaga.aguardandoIngresso);
      },
    );

    test('desistir de vaga que não lotou só desconta a candidatura', () {
      final depois = liberarCandidatura(vaga(candidaturas: 2));

      expect(depois.candidaturas, 1);
      expect(depois.situacao, SituacaoVaga.aguardandoIngresso);
    });

    test('a contagem nunca fica negativa', () {
      expect(liberarCandidatura(vaga()).candidaturas, 0);
    });
  });
}
