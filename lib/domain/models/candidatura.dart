class Candidatura {
  const Candidatura({required this.alunoId, required this.vagaId});

  final String alunoId;
  final String vagaId;
}

/// Onde as candidaturas ficam: o Firestore no app, a memória nos testes.
abstract class RepositorioCandidaturas {
  /// As vagas em que o jovem tem candidatura ativa.
  Future<List<String>> carregar(String jovemId);

  /// Grava a lista de vagas do jovem. Com [entrou] ou [saiu], atualiza junto
  /// a contagem da vaga publicada e lança VagaNaoDisponivel se ela já não
  /// aceita candidaturas.
  Future<void> salvar(
    String jovemId,
    List<String> vagas, {
    String? entrou,
    String? saiu,
  });
}
