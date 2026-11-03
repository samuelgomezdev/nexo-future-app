import 'package:flutter/foundation.dart';

import '../../domain/autenticacao.dart';
import '../../domain/models/cadastro.dart';

/// Quem está usando o app. O visitante vê vagas e cursos; para agir
/// (candidatar-se, painéis de empresa e oficina), é preciso entrar.
class SessaoViewModel extends ChangeNotifier {
  SessaoViewModel([this._auth, this.permiteCadastro = false]);

  final ServicoAutenticacao? _auth;

  /// Mostra o "Criar conta" (precisa do cadastro configurado no app).
  final bool permiteCadastro;

  bool logado = false;
  Perfil? perfil;

  /// Conta de quem entrou: as ações conferem o e-mail confirmado (RN0001).
  Usuario? usuario;

  /// Sem login configurado (demonstração da Etapa 1), tudo fica liberado.
  bool get exigeLogin => _auth != null;

  bool get podeAgir => !exigeLogin || logado;

  void entrou(Perfil? perfil, {Usuario? usuario}) {
    logado = true;
    this.perfil = perfil;
    this.usuario = usuario;
    notifyListeners();
  }

  /// RF0016: reenvia o link para a conta que acabou de entrar ou se cadastrar.
  /// Devolve false quando o Firebase recusa o envio (cota de e-mails, sem internet).
  Future<bool> reenviarConfirmacao() async {
    try {
      await _auth?.enviarConfirmacaoEmail();
      return true;
    } on Exception {
      return false;
    }
  }

  Future<void> sair() async {
    await _auth?.sair();
    logado = false;
    perfil = null;
    usuario = null;
    notifyListeners();
  }
}
