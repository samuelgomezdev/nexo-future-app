import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/domain/autenticacao.dart';
import 'package:nexo_future_app/domain/models/empresa.dart';
import 'package:nexo_future_app/ui/viewmodels/sessao_viewmodel.dart';

import '../../apoio/autenticacao_falsa.dart';

void main() {
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

  group('Sessão: o visitante vê as telas, mas só age quem entrou', () {
    test('sem login configurado (demonstração), tudo fica liberado', () {
      final sessao = SessaoViewModel();

      expect(sessao.exigeLogin, isFalse);
      expect(sessao.podeAgir, isTrue);
    });

    test('com login, o visitante ainda não pode agir', () {
      final sessao = SessaoViewModel(AutenticacaoFalsa());

      expect(sessao.exigeLogin, isTrue);
      expect(sessao.logado, isFalse);
      expect(sessao.podeAgir, isFalse);
    });

    test('depois de entrar, pode agir e guarda o perfil', () {
      final sessao = SessaoViewModel(AutenticacaoFalsa());
      var avisos = 0;
      sessao.addListener(() => avisos++);

      sessao.entrou(empresa);

      expect(sessao.logado, isTrue);
      expect(sessao.podeAgir, isTrue);
      expect(sessao.perfil, same(empresa));
      expect(avisos, 1);
    });

    test(
      'guarda a conta de quem entrou, para conferir o e-mail (RN0001)',
      () async {
        const usuario = Usuario(
          id: 'uid-ana@email.com',
          email: 'ana@email.com',
          emailVerificado: true,
        );
        final sessao = SessaoViewModel(AutenticacaoFalsa())
          ..entrou(empresa, usuario: usuario);

        expect(sessao.usuario, same(usuario));

        await sessao.sair();

        expect(sessao.usuario, isNull);
      },
    );

    test('conta sem perfil salvo também entra', () {
      final sessao = SessaoViewModel(AutenticacaoFalsa())..entrou(null);

      expect(sessao.logado, isTrue);
      expect(sessao.perfil, isNull);
    });

    test('sair encerra a conta e volta a ser visitante', () async {
      final auth = AutenticacaoFalsa();
      final sessao = SessaoViewModel(auth)..entrou(empresa);

      await sessao.sair();

      expect(auth.saidas, 1);
      expect(sessao.logado, isFalse);
      expect(sessao.perfil, isNull);
      expect(sessao.podeAgir, isFalse);
    });
  });

  group('Reenviar a confirmação do e-mail (RF0016)', () {
    test(
      'reenvia o link para a conta que acabou de entrar ou se cadastrar',
      () async {
        final auth = AutenticacaoFalsa();
        final sessao = SessaoViewModel(auth);
        await auth.entrar('novo@email.com', 'senha-certa');

        expect(await sessao.reenviarConfirmacao(), isTrue);
        expect(auth.confirmacoesEnviadas, ['novo@email.com']);
      },
    );

    test('se o Firebase recusar o envio, avisa sem travar', () async {
      final auth = AutenticacaoFalsa()
        ..falhaEnvioConfirmacao = Exception('QUOTA_EXCEEDED');
      final sessao = SessaoViewModel(auth);

      expect(await sessao.reenviarConfirmacao(), isFalse);
    });
  });
}
