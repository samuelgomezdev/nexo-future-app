import 'erros.dart';
import 'regras/bloqueio_login.dart';

class Usuario {
  const Usuario({
    required this.id,
    required this.email,
    required this.emailVerificado,
  });

  final String id;
  final String email;
  final bool emailVerificado;
}

/// Quem confere e-mail e senha: o Firebase Auth no app, uma versão falsa nos testes.
abstract class ServicoAutenticacao {
  /// Lança [CredenciaisInvalidas] quando o e-mail ou a senha não conferem.
  Future<Usuario> entrar(String email, String senha);
}

/// Login com o bloqueio da RNF0007, contado separadamente para cada e-mail.
class EntrarNaConta {
  EntrarNaConta(this._servico, {DateTime Function()? relogio})
    : _relogio = relogio ?? DateTime.now;

  final ServicoAutenticacao _servico;
  final DateTime Function() _relogio;
  final _controles = <String, ControleTentativasLogin>{};

  Future<Usuario> entrar(String email, String senha) async {
    final emailNormalizado = email.trim().toLowerCase();
    final controle = _controles.putIfAbsent(
      emailNormalizado,
      () => ControleTentativasLogin(relogio: _relogio),
    );
    controle.garantirLiberado();

    final Usuario usuario;
    try {
      usuario = await _servico.entrar(emailNormalizado, senha);
    } on CredenciaisInvalidas {
      controle.registrarFalha();
      // Acabou de bloquear: o tempo é o bloqueio inteiro.
      if (controle.bloqueado) throw const LoginBloqueado(tempoBloqueioLogin);
      throw SenhaIncorreta(controle.tentativasRestantes);
    }
    controle.registrarSucesso();

    if (!usuario.emailVerificado) throw const EmailNaoVerificado();
    return usuario;
  }
}
