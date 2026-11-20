import 'package:flutter/foundation.dart';

import '../../data/vaga_repository.dart';
import '../../domain/models/vaga.dart';

/// F1: lista de vagas com pesquisa por texto e área, carregada de 15 em 15.
class VagasViewModel extends ChangeNotifier {
  VagasViewModel(this._repositorio) {
    _carregarPrimeiraPagina();
  }

  final VagaRepository _repositorio;

  final List<Vaga> _vagas = [];
  String _texto = '';
  String? _areaSelecionada;
  int _pagina = 1;
  bool _temMais = true;
  bool _descartado = false;

  /// Aviso quando as vagas publicadas não puderam ser buscadas.
  String? erroAtualizacao;

  List<Vaga> get vagas => List.unmodifiable(_vagas);
  String get texto => _texto;
  String? get areaSelecionada => _areaSelecionada;
  bool get temMais => _temMais;
  List<String> get areas => _repositorio.areas;

  /// A versão mais recente da vaga, mesmo fora da página carregada.
  Vaga? buscarPorId(String id) => _repositorio.buscarPorId(id);

  void pesquisar(String texto) {
    _texto = texto;
    _carregarPrimeiraPagina();
    notifyListeners();
  }

  void filtrarArea(String? area) {
    _areaSelecionada = area;
    _carregarPrimeiraPagina();
    notifyListeners();
  }

  /// True enquanto as vagas publicadas estão sendo buscadas.
  bool get carregando => _carregando;
  bool _carregando = false;

  /// Busca as vagas publicadas (Firestore) e refaz a pesquisa atual. Com a
  /// internet lenta, mostra antes as vagas guardadas no aparelho.
  Future<void> atualizar() async {
    _carregando = true;
    await _mostrarGuardadas();
    try {
      await _repositorio.atualizar();
      erroAtualizacao = null;
    } on Exception {
      erroAtualizacao = 'Não foi possível buscar as vagas mais novas. Puxe a lista para tentar de novo.';
    }
    _carregando = false;
    if (_descartado) return;
    _carregarPrimeiraPagina();
    notifyListeners();
  }

  Future<void> _mostrarGuardadas() async {
    try {
      if (!await _repositorio.carregarGuardadas() || _descartado) return;
    } on Exception {
      return;
    }
    _carregarPrimeiraPagina();
    notifyListeners();
  }

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }

  void carregarMais() {
    if (!_temMais) return;
    _pagina++;
    _acrescentarPagina();
    notifyListeners();
  }

  void _carregarPrimeiraPagina() {
    _vagas.clear();
    _pagina = 1;
    _acrescentarPagina();
  }

  void _acrescentarPagina() {
    final pagina = _repositorio.pesquisar(
      texto: _texto,
      area: _areaSelecionada,
      pagina: _pagina,
    );
    _vagas.addAll(pagina);
    _temMais =
        pagina.length == tamanhoPagina &&
        _repositorio
            .pesquisar(
              texto: _texto,
              area: _areaSelecionada,
              pagina: _pagina + 1,
            )
            .isNotEmpty;
  }
}
