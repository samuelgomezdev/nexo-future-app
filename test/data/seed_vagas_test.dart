import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/data/seed_vagas.dart';
import 'package:nexo_future_app/domain/models/vaga.dart';
import 'package:nexo_future_app/domain/regras/vinculo_cursos.dart';

void main() {
  group('Seed de vagas fictícias da região da AMFRI', () {
    test('tem mais de 30 vagas, o bastante para mais de duas páginas', () {
      expect(seedVagas.length, greaterThan(30));
    });

    test('não repete o id de nenhuma vaga', () {
      final ids = seedVagas.map((v) => v.id).toSet();

      expect(ids, hasLength(seedVagas.length));
    });

    test('nenhuma vaga passa de 5 cursos vinculados (RN0006)', () {
      for (final vaga in seedVagas) {
        expect(vaga.cursos.length, lessThanOrEqualTo(limiteCursosPorVaga),
            reason: vaga.id);
      }
    });

    test('vaga aguardando ingresso tem pelo menos um curso aprovado', () {
      final aguardando = seedVagas
          .where((v) => v.situacao == SituacaoVaga.aguardandoIngresso);

      for (final vaga in aguardando) {
        expect(vaga.cursos, isNotEmpty, reason: vaga.id);
      }
    });

    test('vaga aberta ainda não tem curso aprovado', () {
      final abertas =
          seedVagas.where((v) => v.situacao == SituacaoVaga.aberta);

      expect(abertas, isNotEmpty);
      for (final vaga in abertas) {
        expect(vaga.cursos, isEmpty, reason: vaga.id);
      }
    });

    test('tem vagas lotadas para demonstrar a recusa', () {
      expect(
        seedVagas.where((v) => v.situacao == SituacaoVaga.lotada),
        isNotEmpty,
      );
    });

    test('a primeira vaga aceita candidatura (fluxo de 3 toques)', () {
      expect(seedVagas.first.situacao, SituacaoVaga.aguardandoIngresso);
    });

    test('todas as vagas ficam em cidades da região da AMFRI', () {
      const cidades = {
        'Itajaí',
        'Balneário Camboriú',
        'Navegantes',
        'Itapema',
        'Camboriú',
      };

      for (final vaga in seedVagas) {
        expect(cidades, contains(vaga.cidade), reason: vaga.id);
      }
    });
  });
}
