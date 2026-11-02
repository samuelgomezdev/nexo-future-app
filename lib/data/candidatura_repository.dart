import '../domain/models/candidatura.dart';
import '../domain/models/vaga.dart';
import '../domain/regras/limite_candidaturas.dart';
import '../domain/regras/situacao_vaga.dart';
import 'candidaturas_em_memoria.dart';

/// As candidaturas de quem está usando o app, guardadas na [fonte]
/// (o Firestore no app; sem ela, só no aparelho).
class CandidaturaRepository {
  CandidaturaRepository({
    required String alunoId,
    RepositorioCandidaturas? fonte,
  }) : _alunoId = alunoId,
       _inicial = alunoId,
       _fonte = fonte ?? CandidaturasEmMemoria(),
       _candidaturas = CandidaturasDoAluno(alunoId: alunoId);

  final String _inicial;
  final RepositorioCandidaturas _fonte;
  String _alunoId;
  CandidaturasDoAluno _candidaturas;

  List<Candidatura> get ativas => _candidaturas.ativas;

  bool jaCandidatou(String vagaId) => ativas.any((c) => c.vagaId == vagaId);

  List<String> get _vagas => [for (final c in ativas) c.vagaId];

  /// Carrega as candidaturas já salvas do jovem que entrou.
  Future<void> entrar(String jovemId) async {
    final salvas = await _fonte.carregar(jovemId);
    _alunoId = jovemId;
    _candidaturas = CandidaturasDoAluno(alunoId: jovemId, vagas: salvas);
  }

  /// Quem saiu deixa de ver as candidaturas no aparelho.
  void sair() {
    _alunoId = _inicial;
    _candidaturas = CandidaturasDoAluno(alunoId: _inicial);
  }

  /// Aplica RF0007 (situação da vaga) e RN0005 (limite de 5). Se a gravação
  /// falhar, a candidatura é desfeita.
  Future<void> candidatar(Vaga vaga) async {
    garantirVagaDisponivel(vaga);
    _candidaturas.candidatar(vaga.id);
    try {
      await _fonte.salvar(_alunoId, _vagas, entrou: vaga.id);
    } on Exception {
      _candidaturas.desistir(vaga.id);
      rethrow;
    }
  }

  /// Desistir libera um espaço no limite e uma posição na vaga.
  Future<void> desistir(String vagaId) async {
    _candidaturas.desistir(vagaId);
    try {
      await _fonte.salvar(_alunoId, _vagas, saiu: vagaId);
    } on Exception {
      _candidaturas = CandidaturasDoAluno(
        alunoId: _alunoId,
        vagas: [..._vagas, vagaId],
      );
      rethrow;
    }
  }
}
