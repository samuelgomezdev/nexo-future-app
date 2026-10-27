/// Lançada quando o aluno já tem o máximo de candidaturas ativas (RN0005).
class LimiteCandidaturasAtingido implements Exception {
  const LimiteCandidaturasAtingido();

  @override
  String toString() =>
      'Você já tem 5 candidaturas ativas. Desista de uma para se candidatar a outra vaga.';
}

/// Lançada quando o aluno tenta se candidatar de novo à mesma vaga.
class CandidaturaDuplicada implements Exception {
  const CandidaturaDuplicada();

  @override
  String toString() => 'Você já se candidatou a esta vaga.';
}

/// Lançada quando a vaga não está aguardando ingresso (RF0007).
class VagaNaoDisponivel implements Exception {
  const VagaNaoDisponivel();

  @override
  String toString() => 'Esta vaga não está recebendo candidaturas no momento.';
}

/// Lançada quando a vaga já tem o máximo de cursos vinculados (RN0006).
class LimiteCursosAtingido implements Exception {
  const LimiteCursosAtingido();

  @override
  String toString() => 'Esta vaga já tem 5 cursos vinculados.';
}

/// Lançada quando o login está bloqueado por senhas erradas (RNF0007).
class LoginBloqueado implements Exception {
  const LoginBloqueado(this.tempoRestante);

  final Duration tempoRestante;

  @override
  String toString() {
    final minutos = (tempoRestante.inSeconds / 60).ceil();
    return 'Acesso bloqueado por segurança. Tente de novo em $minutos min.';
  }
}

/// Lançada pelo serviço de autenticação quando o e-mail ou a senha não conferem.
class CredenciaisInvalidas implements Exception {
  const CredenciaisInvalidas();

  @override
  String toString() => 'E-mail ou senha incorretos.';
}

/// Lançada no login com senha errada, antes de chegar ao bloqueio.
class SenhaIncorreta implements Exception {
  const SenhaIncorreta(this.tentativasRestantes);

  final int tentativasRestantes;

  @override
  String toString() => tentativasRestantes == 1
      ? 'E-mail ou senha incorretos. Resta 1 tentativa.'
      : 'E-mail ou senha incorretos. Restam $tentativasRestantes tentativas.';
}

/// Lançada quando a conta ainda não confirmou o e-mail.
class EmailNaoVerificado implements Exception {
  const EmailNaoVerificado();

  @override
  String toString() =>
      'Confirme seu e-mail pelo link que enviamos antes de entrar.';
}

/// Lançada no cadastro quando já existe conta com o e-mail.
class EmailJaCadastrado implements Exception {
  const EmailJaCadastrado();

  @override
  String toString() => 'Já existe uma conta com este e-mail. Tente entrar.';
}

/// Lançada quando o curso já está vinculado à vaga.
class CursoJaVinculado implements Exception {
  const CursoJaVinculado();

  @override
  String toString() => 'Este curso já está vinculado à vaga.';
}
