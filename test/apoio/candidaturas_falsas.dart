import 'package:nexo_future_app/data/candidaturas_em_memoria.dart';

/// Candidaturas em memória que, quando pedido, simulam uma falha de conexão.
class CandidaturasFalsas extends CandidaturasEmMemoria {
  CandidaturasFalsas([super.vagas]);

  Exception? falhaInesperada;

  @override
  Future<void> salvar(
    String jovemId,
    List<String> vagas, {
    String? entrou,
    String? saiu,
  }) async {
    final falha = falhaInesperada;
    if (falha != null) throw falha;
    await super.salvar(jovemId, vagas, entrou: entrou, saiu: saiu);
  }
}
