import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/domain/erros.dart';
import 'package:nexo_future_app/domain/models/vaga.dart';
import 'package:nexo_future_app/domain/regras/situacao_vaga.dart';

void main() {
  group('RF0007: só vaga aguardando ingresso aceita candidatura', () {
    Vaga vagaNaSituacao(SituacaoVaga situacao) => Vaga(
          id: 'vaga-1',
          titulo: 'Soldador',
          empresa: 'MetalSul Usinagem',
          area: 'Metalurgia',
          cidade: 'Itajaí',
          qualificacao: 'Ensino fundamental completo',
          situacao: situacao,
        );

    test('vaga aguardando ingresso aceita candidatura', () {
      final vaga = vagaNaSituacao(SituacaoVaga.aguardandoIngresso);

      expect(() => garantirVagaDisponivel(vaga), returnsNormally);
    });

    test('vaga aberta, sem curso aprovado, recusa candidatura', () {
      final vaga = vagaNaSituacao(SituacaoVaga.aberta);

      expect(
        () => garantirVagaDisponivel(vaga),
        throwsA(isA<VagaNaoDisponivel>()),
      );
    });

    test('vaga lotada recusa candidatura', () {
      final vaga = vagaNaSituacao(SituacaoVaga.lotada);

      expect(
        () => garantirVagaDisponivel(vaga),
        throwsA(isA<VagaNaoDisponivel>()),
      );
    });
  });
}
