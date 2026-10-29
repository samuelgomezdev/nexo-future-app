import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/domain/autenticacao.dart';
import 'package:nexo_future_app/domain/models/empresa.dart';
import 'package:nexo_future_app/domain/regras/bloqueio_login.dart';
import 'package:nexo_future_app/ui/viewmodels/login_viewmodel.dart';

import '../../apoio/autenticacao_falsa.dart';
import '../../apoio/perfis_falsos.dart';

void main() {
  group('LoginViewModel', () {
    late AutenticacaoFalsa servico;
    late PerfisFalsos perfis;
    late LoginViewModel viewModel;

    setUp(() {
      servico = AutenticacaoFalsa();
      perfis = PerfisFalsos();
      viewModel = LoginViewModel(EntrarNaConta(servico), perfis: perfis);
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

    test('falha que não é de senha mostra aviso e não conta como tentativa', () async {
      servico.falhaInesperada = Exception('sem conexão');

      final entrou = await viewModel.entrar('ana@email.com', 'senha-certa');

      expect(entrou, isFalse);
      expect(
        viewModel.erroGeral,
        'Não foi possível entrar agora. Confira sua internet e tente de novo.',
      );
      expect(viewModel.carregando, isFalse);

      servico.falhaInesperada = null;
      await viewModel.entrar('ana@email.com', 'senha-errada');
      expect(
        viewModel.erroSenha,
        'E-mail ou senha incorretos. Restam 4 tentativas.',
      );
    });

    test('depois de entrar, carrega o perfil de quem entrou', () async {
      final empresa = PerfilEmpresa(
        id: 'uid-ana@email.com',
        nome: 'Estaleiro Foz Azul Ltda.',
        cnpj: '11222333000181',
        setor: 'Naval',
        recrutador: 'Marcos Pereira',
        email: 'ana@email.com',
        cidade: 'Itajaí',
        aceitePoliticaEm: DateTime(2026, 10, 29),
      );
      perfis.empresas[empresa.id] = empresa;

      await viewModel.entrar('ana@email.com', 'senha-certa');

      expect(viewModel.perfil, same(empresa));
    });

    test('conta sem perfil salvo entra sem perfil', () async {
      final entrou = await viewModel.entrar('ana@email.com', 'senha-certa');

      expect(entrou, isTrue);
      expect(viewModel.perfil, isNull);
    });

    test('falha ao carregar o perfil mostra o aviso geral', () async {
      perfis.falhaInesperada = Exception('sem conexão');

      final entrou = await viewModel.entrar('ana@email.com', 'senha-certa');

      expect(entrou, isFalse);
      expect(
        viewModel.erroGeral,
        'Não foi possível entrar agora. Confira sua internet e tente de novo.',
      );
    });

    test('uma nova tentativa limpa os erros anteriores', () async {
      await viewModel.entrar('ana@email.com', 'senha-errada');

      await viewModel.entrar('ana@email.com', 'senha-certa');

      expect(viewModel.erroSenha, isNull);
      expect(viewModel.erroEmail, isNull);
    });
  });
}
