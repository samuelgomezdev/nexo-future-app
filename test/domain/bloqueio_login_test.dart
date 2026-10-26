import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/domain/erros.dart';
import 'package:nexo_future_app/domain/regras/bloqueio_login.dart';

void main() {
  group('RNF0007: bloqueio de 15 min após 5 senhas erradas', () {
    late DateTime agora;
    late ControleTentativasLogin controle;

    setUp(() {
      agora = DateTime(2026, 10, 26, 21);
      controle = ControleTentativasLogin(relogio: () => agora);
    });

    void errarSenha(int vezes) {
      for (var i = 0; i < vezes; i++) {
        controle.registrarFalha();
      }
    }

    test('o limite é de 5 tentativas e o bloqueio dura 15 minutos', () {
      expect(maximoTentativasLogin, 5);
      expect(tempoBloqueioLogin, const Duration(minutes: 15));
    });

    test('sem erros, o login está liberado com 5 tentativas', () {
      expect(controle.bloqueado, isFalse);
      expect(controle.tentativasRestantes, 5);
      controle.garantirLiberado();
    });

    test('com 4 senhas erradas, ainda libera e resta 1 tentativa', () {
      errarSenha(4);

      expect(controle.bloqueado, isFalse);
      expect(controle.tentativasRestantes, 1);
      controle.garantirLiberado();
    });

    test('a 5ª senha errada bloqueia o login por 15 minutos', () {
      errarSenha(5);

      expect(controle.bloqueado, isTrue);
      expect(controle.tentativasRestantes, 0);
      expect(controle.tempoRestante, const Duration(minutes: 15));
      expect(
        controle.garantirLiberado,
        throwsA(
          isA<LoginBloqueado>().having(
            (e) => e.tempoRestante,
            'tempoRestante',
            const Duration(minutes: 15),
          ),
        ),
      );
    });

    test('com 14 min e 59 s de bloqueio, continua bloqueado', () {
      errarSenha(5);

      agora = agora.add(const Duration(minutes: 14, seconds: 59));

      expect(controle.bloqueado, isTrue);
      expect(controle.tempoRestante, const Duration(seconds: 1));
    });

    test('depois de 15 minutos, libera e devolve as 5 tentativas', () {
      errarSenha(5);

      agora = agora.add(tempoBloqueioLogin);

      expect(controle.bloqueado, isFalse);
      expect(controle.tempoRestante, Duration.zero);
      expect(controle.tentativasRestantes, 5);
      controle.garantirLiberado();
    });

    test('errar de novo durante o bloqueio não aumenta o tempo', () {
      errarSenha(5);
      agora = agora.add(const Duration(minutes: 5));

      controle.registrarFalha();

      expect(controle.tempoRestante, const Duration(minutes: 10));
    });

    test('acertar a senha zera as tentativas erradas', () {
      errarSenha(4);

      controle.registrarSucesso();
      errarSenha(4);

      expect(controle.bloqueado, isFalse);
      expect(controle.tentativasRestantes, 1);
    });
  });
}
