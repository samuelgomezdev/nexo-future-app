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

/// Lançada quando a vaga não está aguardando ingresso (RF0007).
class VagaNaoDisponivel implements Exception {
  const VagaNaoDisponivel();

  @override
  String toString() => 'Esta vaga não está recebendo candidaturas no momento.';
}
