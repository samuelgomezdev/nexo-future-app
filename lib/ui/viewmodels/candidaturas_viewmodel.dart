import 'package:flutter/foundation.dart';

import '../../data/candidatura_repository.dart';
import '../../data/vaga_repository.dart';
import '../../domain/erros.dart';
import '../../domain/models/vaga.dart';
import '../../domain/regras/limite_candidaturas.dart';

enum ResultadoCandidatura {
  enviada,
  limiteAtingido,
  vagaIndisponivel,
  jaCandidatado,
}

/// F3 e F4: candidatar-se a uma vaga e acompanhar ou desistir das candidaturas.
class CandidaturasViewModel extends ChangeNotifier {
  CandidaturasViewModel(this._candidaturas, this._vagas);

  final CandidaturaRepository _candidaturas;
  final VagaRepository _vagas;

  int get limite => limiteCandidaturasAtivas;
  int get totalAtivas => _candidaturas.ativas.length;
  bool get limiteAtingido => totalAtivas >= limite;

  List<Vaga> get vagasCandidatadas => [
    for (final candidatura in _candidaturas.ativas)
      ?_vagas.buscarPorId(candidatura.vagaId),
  ];

  bool jaCandidatou(Vaga vaga) => _candidaturas.jaCandidatou(vaga.id);

  ResultadoCandidatura candidatar(Vaga vaga) {
    try {
      _candidaturas.candidatar(vaga);
    } on CandidaturaDuplicada {
      return ResultadoCandidatura.jaCandidatado;
    } on VagaNaoDisponivel {
      return ResultadoCandidatura.vagaIndisponivel;
    } on LimiteCandidaturasAtingido {
      return ResultadoCandidatura.limiteAtingido;
    }
    notifyListeners();
    return ResultadoCandidatura.enviada;
  }

  void desistir(Vaga vaga) {
    _candidaturas.desistir(vaga.id);
    notifyListeners();
  }
}
