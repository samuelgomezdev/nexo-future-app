import '../erros.dart';
import '../models/candidatura.dart';

/// RN0005: no máximo 5 candidaturas ativas por aluno.
const limiteCandidaturasAtivas = 5;

class CandidaturasDoAluno {
  /// Começa com as [vagas] em que o aluno já se candidatou.
  CandidaturasDoAluno({required this.alunoId, List<String> vagas = const []})
    : _ativas = [
        for (final vagaId in vagas)
          Candidatura(alunoId: alunoId, vagaId: vagaId),
      ];

  final String alunoId;
  final List<Candidatura> _ativas;

  List<Candidatura> get ativas => List.unmodifiable(_ativas);

  void candidatar(String vagaId) {
    if (_ativas.any((c) => c.vagaId == vagaId)) {
      throw const CandidaturaDuplicada();
    }
    if (_ativas.length >= limiteCandidaturasAtivas) {
      throw const LimiteCandidaturasAtingido();
    }
    _ativas.add(Candidatura(alunoId: alunoId, vagaId: vagaId));
  }

  /// Desistir libera uma vaga do limite.
  void desistir(String vagaId) {
    _ativas.removeWhere((c) => c.vagaId == vagaId);
  }
}
