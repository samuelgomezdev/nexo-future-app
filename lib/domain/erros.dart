/// Lançada quando o aluno já tem o máximo de candidaturas ativas (RN0005).
class LimiteCandidaturasAtingido implements Exception {
  const LimiteCandidaturasAtingido();

  @override
  String toString() =>
      'Você já tem 5 candidaturas ativas. Desista de uma para se candidatar a outra vaga.';
}

/// Lançada quando o aluno tenta se candidatar de novo à mesma vaga.
class CandidaturaDuplicada implements Exception {
  const CandidaturaDuplicada();

  @override
  String toString() => 'Você já se candidatou a esta vaga.';
}
