import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/domain/autenticacao.dart';
import 'package:nexo_future_app/domain/erros.dart';
import 'package:nexo_future_app/domain/regras/bloqueio_login.dart';

/// Serviço de autenticação falso: simula o Firebase Auth em memória.
class AutenticacaoFalsa implements ServicoAutenticacao {
  final contas = <String, ({String senha, bool emailVerificado})>{
    'ana@email.com': (senha: 'senha-certa', emailVerificado: true),
    'bia@email.com': (senha: 'senha-certa', emailVerificado: true),
    'novo@email.com': (senha: 'senha-certa', emailVerificado: false),
  };
  int chamadas = 0;

  @override
  Future<Usuario> entrar(String email, String senha) async {
    chamadas++;
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
}

void main() {
  group('Login com bloqueio por e-mail (RNF0007)', () {
    late DateTime agora;
    late AutenticacaoFalsa servico;
    late EntrarNaConta login;

    setUp(() {
      agora = DateTime(2026, 10, 27, 10);
      servico = AutenticacaoFalsa();
      login = EntrarNaConta(servico, relogio: () => agora);
    });

    Future<void> errarSenha(String email, int vezes) async {
      for (var i = 0; i < vezes; i++) {
        await expectLater(
          login.entrar(email, 'senha-errada'),
          throwsA(anything),
        );
      }
    }

    test('com a senha certa, entra e devolve o usuário', () async {
      final usuario = await login.entrar('ana@email.com', 'senha-certa');

      expect(usuario.email, 'ana@email.com');
    });

    test('com a senha errada, avisa quantas tentativas restam', () async {
      await expectLater(
        login.entrar('ana@email.com', 'senha-errada'),
        throwsA(
          isA<SenhaIncorreta>().having(
            (e) => e.tentativasRestantes,
            'tentativasRestantes',
            4,
          ),
        ),
      );
    });

    test('a 5ª senha errada bloqueia por 15 minutos', () async {
      await errarSenha('ana@email.com', 4);

      await expectLater(
        login.entrar('ana@email.com', 'senha-errada'),
        throwsA(
          isA<LoginBloqueado>().having(
            (e) => e.tempoRestante,
            'tempoRestante',
            tempoBloqueioLogin,
          ),
        ),
      );
    });

    test(
      'bloqueado, recusa até a senha certa sem consultar o servidor',
      () async {
        await errarSenha('ana@email.com', 5);
        final chamadasAntes = servico.chamadas;

        await expectLater(
          login.entrar('ana@email.com', 'senha-certa'),
          throwsA(isA<LoginBloqueado>()),
        );
        expect(servico.chamadas, chamadasAntes);
      },
    );

    test('passados 15 minutos, entra com a senha certa', () async {
      await errarSenha('ana@email.com', 5);

      agora = agora.add(tempoBloqueioLogin);
      final usuario = await login.entrar('ana@email.com', 'senha-certa');

      expect(usuario.email, 'ana@email.com');
    });

    test('o bloqueio de um e-mail não afeta outro', () async {
      await errarSenha('ana@email.com', 5);

      final usuario = await login.entrar('bia@email.com', 'senha-certa');

      expect(usuario.email, 'bia@email.com');
    });

    test(
      'o e-mail é comparado sem espaços e sem diferenciar maiúsculas',
      () async {
        await errarSenha(' Ana@Email.com ', 5);

        await expectLater(
          login.entrar('ana@email.com', 'senha-certa'),
          throwsA(isA<LoginBloqueado>()),
        );
      },
    );

    test('com o e-mail ainda não confirmado, pede a confirmação', () async {
      await expectLater(
        login.entrar('novo@email.com', 'senha-certa'),
        throwsA(isA<EmailNaoVerificado>()),
      );
    });
  });
}
