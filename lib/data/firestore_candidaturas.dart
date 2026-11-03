import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/models/candidatura.dart';
import '../domain/models/vaga.dart';
import '../domain/regras/situacao_vaga.dart';
import 'mapa_vagas.dart';

/// Guarda a lista de candidaturas de cada jovem (coleção candidaturas) e a
/// contagem na vaga publicada. As regras estão em firestore.rules.
class FirestoreCandidaturas implements RepositorioCandidaturas {
  FirestoreCandidaturas([FirebaseFirestore? banco])
    : _banco = banco ?? FirebaseFirestore.instance;

  final FirebaseFirestore _banco;

  DocumentReference<Map<String, dynamic>> _lista(String jovemId) =>
      _banco.collection('candidaturas').doc(jovemId);

  @override
  Future<List<String>> carregar(String jovemId) async {
    final doc = await _lista(jovemId).get();
    return [...?(doc.data()?['vagas'] as List?)?.cast<String>()];
  }

  /// Numa transação: relê a vaga no servidor, aplica a regra (que lota a vaga
  /// ou recusa a candidatura) e grava a lista e a contagem juntas.
  @override
  Future<void> salvar(
    String jovemId,
    List<String> vagas, {
    String? entrou,
    String? saiu,
  }) {
    return _banco.runTransaction((transacao) async {
      final idVaga = entrou ?? saiu;
      final referencia = idVaga == null
          ? null
          : _banco.collection('vagas').doc(idVaga);
      Vaga? atualizada;
      if (referencia != null) {
        final dados = (await transacao.get(referencia)).data();
        // Vaga que não está no Firestore (apagada) não tem contagem.
        if (dados != null) {
          final vaga = vagaDoMapa(referencia.id, dados);
          atualizada = entrou != null
              ? registrarCandidatura(vaga)
              : liberarCandidatura(vaga);
        }
      }
      transacao.set(_lista(jovemId), {
        'vagas': vagas,
        'atualizadoEm': FieldValue.serverTimestamp(),
      });
      if (referencia != null && atualizada != null) {
        transacao.update(referencia, {
          'candidaturas': atualizada.candidaturas,
          'situacao': atualizada.situacao.name,
        });
      }
    });
  }
}
