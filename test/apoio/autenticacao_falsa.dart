import 'package:nexo_future_app/domain/autenticacao.dart';
import 'package:nexo_future_app/domain/erros.dart';

/// Serviço de autenticação falso: simula o Firebase Auth em memória.
class AutenticacaoFalsa implements ServicoAutenticacao {
  final contas = <String, ({String senha, bool emailVerificado})>{
    'ana@email.com': (senha: 'senha-certa', emailVerificado: true),
    'bia@email.com': (senha: 'senha-certa', emailVerificado: true),
    'novo@email.com': (senha: 'senha-certa', emailVerificado: false),
  };
  int chamadas = 0;

  /// E-mails que receberam o link de confirmação.
  final confirmacoesEnviadas = <String>[];

  /// Quantas vezes a pessoa saiu da conta.
  int saidas = 0;
  String? _ultimaContaCriada;

  /// Simula uma falha que não é de senha (sem internet, servidor fora etc.).
  Exception? falhaInesperada;

  @override
  Future<Usuario> entrar(String email, String senha) async {
    chamadas++;
    final falha = falhaInesperada;
    if (falha != null) throw falha;
    final conta = contas[email];
    if (conta == null || conta.senha != senha) {
      throw const CredenciaisInvalidas();
    }
    return Usuario(
      id: 'uid-$email',
      email: email,
      emailVerificado: conta.emailVerificado,
    );
  }

  @override
  Future<Usuario> criarConta(String email, String senha) async {
    final falha = falhaInesperada;
    if (falha != null) throw falha;
    if (contas.containsKey(email)) throw const EmailJaCadastrado();
    contas[email] = (senha: senha, emailVerificado: false);
    _ultimaContaCriada = email;
    return Usuario(id: 'uid-$email', email: email, emailVerificado: false);
  }

  @override
  Future<void> enviarConfirmacaoEmail() async {
    final email = _ultimaContaCriada;
    if (email != null) confirmacoesEnviadas.add(email);
  }

  @override
  Future<void> sair() async {
    saidas++;
  }
}
