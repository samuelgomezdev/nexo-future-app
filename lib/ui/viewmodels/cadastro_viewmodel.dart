import 'package:flutter/foundation.dart';

import '../../domain/erros.dart';
import '../../domain/models/cadastro.dart';

/// Fluxo comum dos cadastros: aponta os erros por campo e mostra o carregamento.
class CadastroViewModel<D, P> extends ChangeNotifier {
  CadastroViewModel(this._cadastrar);

  final Future<P> Function(D dados) _cadastrar;

  Map<CampoCadastro, String> erros = const {};
  String? erroGeral;
  bool carregando = false;
  P? perfil;

  /// Quando a pessoa edita um campo, o erro dele some na hora.
  void limparErro(CampoCadastro campo) {
    if (!erros.containsKey(campo)) return;
    erros = {...erros}..remove(campo);
    notifyListeners();
  }

  /// Mostra só os erros dos campos da etapa; devolve true quando ela pode avançar.
  bool conferirEtapa(
    Map<CampoCadastro, String> todosOsErros,
    Set<CampoCadastro> campos,
  ) {
    erros = {
      for (final erro in todosOsErros.entries)
        if (campos.contains(erro.key)) erro.key: erro.value,
    };
    erroGeral = null;
    notifyListeners();
    return erros.isEmpty;
  }

  Future<bool> cadastrar(D dados) async {
    erros = const {};
    erroGeral = null;
    carregando = true;
    notifyListeners();
    try {
      perfil = await _cadastrar(dados);
      return true;
    } on CadastroInvalido catch (e) {
      erros = e.erros;
    } on EmailJaCadastrado catch (e) {
      erros = {CampoCadastro.email: e.toString()};
    } on Exception {
      erroGeral = 'Não foi possível criar a conta agora. Confira sua internet e tente de novo.';
    } finally {
      carregando = false;
      notifyListeners();
    }
    return false;
  }
}
