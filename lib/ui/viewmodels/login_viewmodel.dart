import 'package:flutter/foundation.dart';

import '../../domain/autenticacao.dart';
import '../../domain/erros.dart';

final _formatoEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Login (protótipo A2 a A5): valida os campos, entra e explica o que deu errado.
class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this._login);

  final EntrarNaConta _login;

  bool carregando = false;
  String? erroEmail;
  String? erroSenha;

  /// Falha que não é de e-mail nem de senha (internet, servidor).
  String? erroGeral;
  Usuario? usuario;
  bool precisaConfirmarEmail = false;
  Duration? tempoBloqueio;

  bool get bloqueado => tempoBloqueio != null;

  Future<bool> entrar(String email, String senha) async {
    erroEmail = null;
    erroSenha = null;
    erroGeral = null;
    precisaConfirmarEmail = false;
    tempoBloqueio = null;

    final emailLimpo = email.trim();
    if (emailLimpo.isEmpty) {
      erroEmail = 'Informe seu e-mail.';
    } else if (!_formatoEmail.hasMatch(emailLimpo)) {
      erroEmail = 'Informe um e-mail válido.';
    }
    if (senha.isEmpty) erroSenha = 'Informe sua senha.';
    if (erroEmail != null || erroSenha != null) {
      notifyListeners();
      return false;
    }

    carregando = true;
    notifyListeners();
    try {
      usuario = await _login.entrar(emailLimpo, senha);
      return true;
    } on SenhaIncorreta catch (e) {
      erroSenha = e.toString();
    } on LoginBloqueado catch (e) {
      tempoBloqueio = e.tempoRestante;
    } on EmailNaoVerificado {
      precisaConfirmarEmail = true;
    } on Exception {
      erroGeral = 'Não foi possível entrar agora. Confira sua internet e tente de novo.';
    } finally {
      carregando = false;
      notifyListeners();
    }
    return false;
  }
}
