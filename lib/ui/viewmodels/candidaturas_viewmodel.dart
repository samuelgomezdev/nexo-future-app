import 'package:flutter/foundation.dart';

import '../../data/candidatura_repository.dart';
import '../../data/vaga_repository.dart';
import '../../domain/erros.dart';
import '../../domain/models/vaga.dart';
import '../../domain/regras/limite_candidaturas.dart';
import 'sessao_viewmodel.dart';

enum ResultadoCandidatura {
  enviada,
  limiteAtingido,
  vagaIndisponivel,
  jaCandidatado,

  /// Sem internet ou servidor fora: nada foi gravado.
  falhaConexao,
}

/// F3 e F4: candidatar-se a uma vaga e acompanhar ou desistir das candidaturas.
class CandidaturasViewModel extends ChangeNotifier {
  /// Com a [sessao], as candidaturas acompanham a conta de quem entrou.
  CandidaturasViewModel(this._candidaturas, this._vagas, {this.sessao}) {
    sessao?.addListener(_aoMudarSessao);
    // Pode nascer depois do login: já carrega a conta de quem entrou.
    _aoMudarSessao();
  }

  final CandidaturaRepository _candidaturas;
  final VagaRepository _vagas;
  final SessaoViewModel? sessao;
  String? _contaCarregada;
  bool _descartado = false;

  Future<void> _aoMudarSessao() async {
    final conta = sessao?.usuario?.id;
    if (conta == _contaCarregada) return;
    _contaCarregada = conta;
    if (conta == null) {
      _candidaturas.sair();
    } else {
      try {
        await _candidaturas.entrar(conta);
      } on Exception {
        // Sem internet, a lista fica vazia até a próxima entrada.
      }
    }
    if (!_descartado) notifyListeners();
  }

  @override
  void dispose() {
    _descartado = true;
    sessao?.removeListener(_aoMudarSessao);
    super.dispose();
  }

  int get limite => limiteCandidaturasAtivas;
  int get totalAtivas => _candidaturas.ativas.length;
  bool get limiteAtingido => totalAtivas >= limite;

  List<Vaga> get vagasCandidatadas => [
    for (final candidatura in _candidaturas.ativas)
      ?_vagas.buscarPorId(candidatura.vagaId),
  ];

  bool jaCandidatou(Vaga vaga) => _candidaturas.jaCandidatou(vaga.id);

  Future<ResultadoCandidatura> candidatar(Vaga vaga) async {
    try {
      await _candidaturas.candidatar(vaga);
    } on CandidaturaDuplicada {
      return ResultadoCandidatura.jaCandidatado;
    } on VagaNaoDisponivel {
      return ResultadoCandidatura.vagaIndisponivel;
    } on LimiteCandidaturasAtingido {
      return ResultadoCandidatura.limiteAtingido;
    } on Exception {
      return ResultadoCandidatura.falhaConexao;
    }
    notifyListeners();
    return ResultadoCandidatura.enviada;
  }

  /// Devolve false quando a desistência não pôde ser gravada.
  Future<bool> desistir(Vaga vaga) async {
    try {
      await _candidaturas.desistir(vaga.id);
    } on Exception {
      return false;
    }
    notifyListeners();
    return true;
  }
}
