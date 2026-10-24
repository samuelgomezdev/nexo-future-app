import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/domain/erros.dart';
import 'package:nexo_future_app/domain/models/vaga.dart';
import 'package:nexo_future_app/domain/regras/vinculo_cursos.dart';

void main() {
  group('RN0006: no máximo 5 cursos preferenciais por vaga', () {
    Curso curso(int numero) => Curso(
      id: 'curso-$numero',
      nome: 'Curso $numero',
      oficina: 'Oficina Escola Mãos do Porto',
    );

    List<Curso> vincularVarios(int quantidade) {
      var cursos = <Curso>[];
      for (var i = 1; i <= quantidade; i++) {
        cursos = vincularCurso(cursos, curso(i));
      }
      return cursos;
    }

    test('o limite é de 5 cursos por vaga', () {
      expect(limiteCursosPorVaga, 5);
    });

    test('vincula até 5 cursos', () {
      final cursos = vincularVarios(5);

      expect(cursos, hasLength(5));
      expect(cursos.last.id, 'curso-5');
    });

    test('o 6º curso é recusado', () {
      final cursos = vincularVarios(5);

      expect(
        () => vincularCurso(cursos, curso(6)),
        throwsA(isA<LimiteCursosAtingido>()),
      );
    });

    test('o mesmo curso duas vezes é recusado', () {
      final cursos = vincularCurso([], curso(1));

      expect(
        () => vincularCurso(cursos, curso(1)),
        throwsA(isA<CursoJaVinculado>()),
      );
    });
  });
}
