import '../erros.dart';
import '../models/vaga.dart';

/// RN0006: no máximo 5 cursos preferenciais por vaga.
const limiteCursosPorVaga = 5;

/// Devolve uma nova lista com o curso vinculado, sem alterar a original.
List<Curso> vincularCurso(List<Curso> cursos, Curso novo) {
  if (cursos.any((c) => c.id == novo.id)) {
    throw const CursoJaVinculado();
  }
  if (cursos.length >= limiteCursosPorVaga) {
    throw const LimiteCursosAtingido();
  }
  return [...cursos, novo];
}
