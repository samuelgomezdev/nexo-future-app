import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/domain/erros.dart';
import 'package:nexo_future_app/domain/regras/limite_candidaturas.dart';

void main() {
  group('RN0005: limite de 5 candidaturas ativas por aluno', () {
    late CandidaturasDoAluno candidaturas;

    setUp(() {
      candidaturas = CandidaturasDoAluno(alunoId: 'jovem-demo');
    });

    void candidatarEmVarias(int quantidade) {
      for (var i = 1; i <= quantidade; i++) {
        candidaturas.candidatar('vaga-$i');
      }
    }

    test('o limite é de 5 candidaturas ativas', () {
      expect(limiteCandidaturasAtivas, 5);
    });

    test('aluno com 0 candidaturas consegue se candidatar', () {
      candidaturas.candidatar('vaga-1');

      expect(candidaturas.ativas, hasLength(1));
      expect(candidaturas.ativas.single.vagaId, 'vaga-1');
    });

    test('aluno com 4 candidaturas consegue a 5ª', () {
      candidatarEmVarias(4);

      candidaturas.candidatar('vaga-5');

      expect(candidaturas.ativas, hasLength(5));
    });

    test('aluno com 5 candidaturas não consegue a 6ª', () {
      candidatarEmVarias(5);

      expect(
        () => candidaturas.candidatar('vaga-6'),
        throwsA(isA<LimiteCandidaturasAtingido>()),
      );
      expect(candidaturas.ativas, hasLength(5));
    });

    test('aluno com 5 candidaturas desiste de uma e volta a conseguir', () {
      candidatarEmVarias(5);

      candidaturas.desistir('vaga-3');
      candidaturas.candidatar('vaga-6');

      expect(candidaturas.ativas, hasLength(5));
      expect(
        candidaturas.ativas.map((c) => c.vagaId),
        isNot(contains('vaga-3')),
      );
    });

    test('candidatar-se duas vezes na mesma vaga é recusado', () {
      candidaturas.candidatar('vaga-1');

      expect(
        () => candidaturas.candidatar('vaga-1'),
        throwsA(isA<CandidaturaDuplicada>()),
      );
      expect(candidaturas.ativas, hasLength(1));
    });
  });
}
