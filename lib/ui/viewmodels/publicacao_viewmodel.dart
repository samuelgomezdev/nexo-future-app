import 'package:flutter/foundation.dart';

import '../../domain/erros.dart';
import '../../domain/models/cadastro.dart';

/// Fluxo comum de quem publica ou decide algo (vaga, curso, aprovação):
/// aponta os erros por campo, explica as regras e mostra o carregamento.
class PublicacaoViewModel extends ChangeNotifier {
  Map<CampoCadastro, String> erros = const {};
  String? erroGeral;
  bool carregando = false;

  static const erroInternet =
      'Não foi possível salvar agora. Confira sua internet e tente de novo.';

  /// Quando a pessoa edita um campo, o erro dele some na hora.
  void limparErro(CampoCadastro campo) {
    if (!erros.containsKey(campo)) return;
    erros = {...erros}..remove(campo);
    notifyListeners();
  }

  /// Roda a ação e devolve true quando deu certo.
  @protected
  Future<bool> executar(Future<void> Function() acao) async {
    erros = const {};
    erroGeral = null;
    carregando = true;
    notifyListeners();
    try {
      await acao();
      return true;
    } on CadastroInvalido catch (e) {
      erros = e.erros;
    } on Exception catch (e) {
      erroGeral = mensagemDaRegra(e) ?? erroInternet;
    } finally {
      carregando = false;
      notifyListeners();
    }
    return false;
  }
}

/// As regras de negócio já explicam o motivo; outras falhas são de conexão.
String? mensagemDaRegra(Exception erro) => switch (erro) {
  EmailNaoVerificado() ||
  AcaoNaoPermitida() ||
  OficinaSemAlvara() ||
  AlvaraVencido() ||
  LimiteCursosAtingido() ||
  CursoJaVinculado() ||
  CursoJaDecidido() => erro.toString(),
  _ => null,
};
