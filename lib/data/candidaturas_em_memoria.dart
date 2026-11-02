import '../domain/models/candidatura.dart';
import '../domain/models/vaga.dart';
import '../domain/regras/situacao_vaga.dart';
import 'vagas_em_memoria.dart';

/// Candidaturas guardadas só no aparelho: usado quando o app roda sem o
/// Firebase (demonstração) e nos testes. Com as [vagas], conta as candidaturas
/// nas vagas publicadas, como o Firestore faz.
class CandidaturasEmMemoria implements RepositorioCandidaturas {
  CandidaturasEmMemoria([this._vagas]);

  final VagasEmMemoria? _vagas;
  final _porJovem = <String, List<String>>{};

  @override
  Future<List<String>> carregar(String jovemId) async =>
      List.of(_porJovem[jovemId] ?? const []);

  @override
  Future<void> salvar(
    String jovemId,
    List<String> vagas, {
    String? entrou,
    String? saiu,
  }) async {
    final publicadas = _vagas?.vagas;
    Vaga? atualizada;
    if (publicadas != null) {
      if (publicadas[entrou] case final vaga?) {
        atualizada = registrarCandidatura(vaga);
      } else if (publicadas[saiu] case final vaga?) {
        atualizada = liberarCandidatura(vaga);
      }
    }
    _porJovem[jovemId] = List.of(vagas);
    if (atualizada != null) publicadas![atualizada.id] = atualizada;
  }
}
