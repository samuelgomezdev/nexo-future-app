import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/domain/models/jovem.dart';
import 'package:nexo_future_app/domain/regras/cadastro_jovem.dart';
import 'package:nexo_future_app/ui/viewmodels/cadastro_jovem_viewmodel.dart';

import '../../apoio/autenticacao_falsa.dart';
import '../../apoio/perfis_falsos.dart';

void main() {
  final hoje = DateTime(2026, 10, 27);

  group('Data digitada no formato dd/mm/aaaa', () {
    test('lê uma data válida', () {
      expect(lerDataBr('02/03/2009'), DateTime(2009, 3, 2));
      expect(lerDataBr(' 2/3/2009 '), DateTime(2009, 3, 2));
    });

    test('recusa data que não existe ou fora do formato', () {
      expect(lerDataBr('31/02/2009'), isNull);
      expect(lerDataBr('2009-03-02'), isNull);
      expect(lerDataBr(''), isNull);
    });
  });

  group('CadastroJovemViewModel', () {
    late AutenticacaoFalsa auth;
    late PerfisFalsos perfis;
    late CadastroJovemViewModel viewModel;

    setUp(() {
      auth = AutenticacaoFalsa();
      perfis = PerfisFalsos();
      viewModel = CadastroJovemViewModel(
        CadastrarJovem(auth, perfis, relogio: () => hoje),
        relogio: () => hoje,
      );
    });

    DadosCadastroJovem dados({
      String nome = 'Carla Lima',
      String email = 'carla@email.com',
    }) => DadosCadastroJovem(
      nome: nome,
      email: email,
      senha: 'senha1234',
      cidade: 'Itajaí',
      dataNascimento: DateTime(2000, 1, 1),
      autorizacaoResponsavel: false,
      aceitePolitica: true,
    );

    test('pede a autorização do responsável só para quem tem 12 a 17 anos', () {
      expect(viewModel.precisaAutorizacao(DateTime(2010, 1, 1)), isTrue);
      expect(viewModel.precisaAutorizacao(DateTime(2000, 1, 1)), isFalse);
      expect(viewModel.precisaAutorizacao(null), isFalse);
    });

    test('com dados válidos, cadastra e guarda o perfil', () async {
      final cadastrou = await viewModel.cadastrar(dados());

      expect(cadastrou, isTrue);
      expect(viewModel.perfil?.email, 'carla@email.com');
      expect(perfis.jovens, hasLength(1));
      expect(viewModel.carregando, isFalse);
    });

    test('com dados inválidos, mostra o erro de cada campo', () async {
      final cadastrou = await viewModel.cadastrar(dados(nome: 'Carla'));

      expect(cadastrou, isFalse);
      expect(viewModel.erros[CampoCadastro.nome], 'Informe nome e sobrenome.');
    });

    test('e-mail já cadastrado aparece no campo e-mail', () async {
      await viewModel.cadastrar(dados(email: 'ana@email.com'));

      expect(
        viewModel.erros[CampoCadastro.email],
        'Já existe uma conta com este e-mail. Tente entrar.',
      );
    });

    test('falha do servidor mostra um aviso geral', () async {
      auth.falhaInesperada = Exception('sem conexão');

      await viewModel.cadastrar(dados());

      expect(
        viewModel.erroGeral,
        'Não foi possível criar a conta agora. Confira sua internet e tente de novo.',
      );
    });
  });
}
