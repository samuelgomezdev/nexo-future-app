import 'dart:async';

import 'package:nexo_future_app/data/candidaturas_em_memoria.dart';

/// Candidaturas em memória que, quando pedido, simulam uma falha de conexão.
class CandidaturasFalsas extends CandidaturasEmMemoria {
  CandidaturasFalsas([super.vagas]);

  Exception? falhaInesperada;

  /// Segura o carregamento até ser completado, como uma internet lenta.
  Completer<void>? carregamentoLento;

  /// Falha só ao carregar.
  Exception? falhaAoCarregar;

  @override
  Future<List<String>> carregar(String jovemId) async {
    await carregamentoLento?.future;
    final falha = falhaAoCarregar;
    if (falha != null) throw falha;
    return super.carregar(jovemId);
  }

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
