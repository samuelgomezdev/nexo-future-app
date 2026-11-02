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

  /// Termina com true quando as candidaturas salvas já estão no aparelho.
  Future<bool> _carregamento = Future.value(true);

  void _aoMudarSessao() {
    final conta = sessao?.usuario?.id;
    if (conta == _contaCarregada) return;
    _contaCarregada = conta;
    _carregamento = _carregar(conta);
  }

  Future<bool> _carregar(String? conta) async {
    try {
      if (conta == null) {
        _candidaturas.sair();
      } else {
        await _candidaturas.entrar(conta);
      }
      return true;
    } on Exception {
      return false;
    } finally {
      if (!_descartado) notifyListeners();
    }
  }

  /// Antes de gravar, espera as candidaturas salvas: sem elas, a gravação
  /// apagaria as anteriores. Se não carregaram, tenta de novo.
  Future<bool> _prontoParaGravar() async {
    if (await _carregamento) return true;
    _carregamento = _carregar(_contaCarregada);
    return _carregamento;
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
    if (!await _prontoParaGravar()) return ResultadoCandidatura.falhaConexao;
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
    if (!await _prontoParaGravar()) return false;
    try {
      await _candidaturas.desistir(vaga.id);
    } on Exception {
      return false;
    }
    notifyListeners();
    return true;
  }
}
