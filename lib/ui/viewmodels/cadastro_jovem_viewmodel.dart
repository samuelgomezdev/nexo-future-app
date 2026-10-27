import 'package:flutter/foundation.dart';

import '../../domain/erros.dart';
import '../../domain/models/jovem.dart';
import '../../domain/regras/cadastro_jovem.dart';

final _formatoDataBr = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$');

/// Lê uma data digitada como dd/mm/aaaa; devolve null se não existir.
DateTime? lerDataBr(String texto) {
  final partes = _formatoDataBr.firstMatch(texto.trim());
  if (partes == null) return null;
  final dia = int.parse(partes[1]!);
  final mes = int.parse(partes[2]!);
  final data = DateTime(int.parse(partes[3]!), mes, dia);
  // DateTime aceita 31/02 e vira 03/03: confere se a data é a mesma.
  if (data.day != dia || data.month != mes) return null;
  return data;
}

/// C2 do protótipo: cadastro do jovem.
class CadastroJovemViewModel extends ChangeNotifier {
  CadastroJovemViewModel(this._cadastrar, {DateTime Function()? relogio})
    : _relogio = relogio ?? DateTime.now;

  final CadastrarJovem _cadastrar;
  final DateTime Function() _relogio;

  Map<CampoCadastro, String> erros = const {};
  String? erroGeral;
  bool carregando = false;
  PerfilJovem? perfil;

  bool precisaAutorizacao(DateTime? nascimento) {
    if (nascimento == null) return false;
    final idade = idadeEm(nascimento, _relogio());
    return idade >= idadeMinima && idade < maioridade;
  }

  Future<bool> cadastrar(DadosCadastroJovem dados) async {
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
