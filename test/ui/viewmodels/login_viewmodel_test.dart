import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/domain/autenticacao.dart';
import 'package:nexo_future_app/domain/regras/bloqueio_login.dart';
import 'package:nexo_future_app/ui/viewmodels/login_viewmodel.dart';

import '../../apoio/autenticacao_falsa.dart';

void main() {
  group('LoginViewModel', () {
    late AutenticacaoFalsa servico;
    late LoginViewModel viewModel;

    setUp(() {
      servico = AutenticacaoFalsa();
      viewModel = LoginViewModel(EntrarNaConta(servico));
    });

    test('com a senha certa, entra e guarda o usuário', () async {
      final entrou = await viewModel.entrar('ana@email.com', 'senha-certa');

      expect(entrou, isTrue);
      expect(viewModel.usuario?.email, 'ana@email.com');
      expect(viewModel.carregando, isFalse);
    });

    test(
      'e-mail vazio é apontado no campo, sem consultar o servidor',
      () async {
        final entrou = await viewModel.entrar('  ', 'senha-certa');

        expect(entrou, isFalse);
        expect(viewModel.erroEmail, 'Informe seu e-mail.');
        expect(servico.chamadas, 0);
      },
    );

    test('e-mail sem formato válido é apontado no campo', () async {
      await viewModel.entrar('ana@email', 'senha-certa');

      expect(viewModel.erroEmail, 'Informe um e-mail válido.');
      expect(servico.chamadas, 0);
    });

    test('senha vazia é apontada no campo', () async {
      await viewModel.entrar('ana@email.com', '');

      expect(viewModel.erroSenha, 'Informe sua senha.');
      expect(servico.chamadas, 0);
    });

    test(
      'senha errada mostra quantas tentativas restam no campo senha',
      () async {
        final entrou = await viewModel.entrar('ana@email.com', 'senha-errada');

        expect(entrou, isFalse);
        expect(
          viewModel.erroSenha,
          'E-mail ou senha incorretos. Restam 4 tentativas.',
        );
        expect(viewModel.bloqueado, isFalse);
      },
    );

    test('a 5ª senha errada bloqueia por 15 minutos', () async {
      for (var i = 0; i < 5; i++) {
        await viewModel.entrar('ana@email.com', 'senha-errada');
      }

      expect(viewModel.bloqueado, isTrue);
      expect(viewModel.tempoBloqueio, tempoBloqueioLogin);
    });

    test('e-mail não confirmado pede a confirmação', () async {
      final entrou = await viewModel.entrar('novo@email.com', 'senha-certa');

      expect(entrou, isFalse);
      expect(viewModel.precisaConfirmarEmail, isTrue);
    });

    test('uma nova tentativa limpa os erros anteriores', () async {
      await viewModel.entrar('ana@email.com', 'senha-errada');

      await viewModel.entrar('ana@email.com', 'senha-certa');

      expect(viewModel.erroSenha, isNull);
      expect(viewModel.erroEmail, isNull);
    });
  });
}
