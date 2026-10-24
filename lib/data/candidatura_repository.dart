import '../domain/models/candidatura.dart';
import '../domain/models/vaga.dart';
import '../domain/regras/limite_candidaturas.dart';
import '../domain/regras/situacao_vaga.dart';

/// Guarda em memória as candidaturas do aluno (sem backend na Etapa 1).
class CandidaturaRepository {
  CandidaturaRepository({required String alunoId})
    : _candidaturas = CandidaturasDoAluno(alunoId: alunoId);

  final CandidaturasDoAluno _candidaturas;

  List<Candidatura> get ativas => _candidaturas.ativas;

  bool jaCandidatou(String vagaId) => ativas.any((c) => c.vagaId == vagaId);

  /// Aplica RF0007 (situação da vaga) e RN0005 (limite de 5).
  void candidatar(Vaga vaga) {
    garantirVagaDisponivel(vaga);
    _candidaturas.candidatar(vaga.id);
  }

  void desistir(String vagaId) => _candidaturas.desistir(vagaId);
}
