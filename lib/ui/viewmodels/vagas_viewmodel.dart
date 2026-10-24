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

  List<Vaga> get vagas => List.unmodifiable(_vagas);
  String get texto => _texto;
  String? get areaSelecionada => _areaSelecionada;
  bool get temMais => _temMais;
  List<String> get areas => _repositorio.areas;

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
