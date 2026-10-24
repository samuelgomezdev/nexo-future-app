import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/data/candidatura_repository.dart';
import 'package:nexo_future_app/domain/erros.dart';
import 'package:nexo_future_app/domain/models/vaga.dart';

Vaga vaga(
  String id, {
  SituacaoVaga situacao = SituacaoVaga.aguardandoIngresso,
}) => Vaga(
  id: id,
  titulo: 'Soldador',
  empresa: 'MetalSul Usinagem',
  area: 'Metalurgia',
  cidade: 'Itajaí',
  qualificacao: 'Ensino fundamental completo',
  situacao: situacao,
);

void main() {
  group('Repositório de candidaturas do aluno', () {
    late CandidaturaRepository repositorio;

    setUp(() {
      repositorio = CandidaturaRepository(alunoId: 'jovem-demo');
    });

    test('começa sem candidaturas', () {
      expect(repositorio.ativas, isEmpty);
    });

    test('registra a candidatura numa vaga aguardando ingresso', () {
      repositorio.candidatar(vaga('vaga-1'));

      expect(repositorio.ativas.single.vagaId, 'vaga-1');
      expect(repositorio.jaCandidatou('vaga-1'), isTrue);
      expect(repositorio.jaCandidatou('vaga-2'), isFalse);
    });

    test('recusa vaga que não está aguardando ingresso (RF0007)', () {
      expect(
        () => repositorio.candidatar(
          vaga('vaga-1', situacao: SituacaoVaga.lotada),
        ),
        throwsA(isA<VagaNaoDisponivel>()),
      );
      expect(repositorio.ativas, isEmpty);
    });

    test('recusa a 6ª candidatura (RN0005)', () {
      for (var i = 1; i <= 5; i++) {
        repositorio.candidatar(vaga('vaga-$i'));
      }

      expect(
        () => repositorio.candidatar(vaga('vaga-6')),
        throwsA(isA<LimiteCandidaturasAtingido>()),
      );
    });

    test('desistir remove a candidatura', () {
      repositorio.candidatar(vaga('vaga-1'));

      repositorio.desistir('vaga-1');

      expect(repositorio.ativas, isEmpty);
      expect(repositorio.jaCandidatou('vaga-1'), isFalse);
    });
  });
}
