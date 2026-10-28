import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/domain/models/cadastro.dart';
import 'package:nexo_future_app/domain/models/empresa.dart';
import 'package:nexo_future_app/domain/models/oficina.dart';
import 'package:nexo_future_app/domain/regras/cadastro_empresa.dart';
import 'package:nexo_future_app/domain/regras/cadastro_oficina.dart';
import 'package:nexo_future_app/ui/viewmodels/cadastro_empresa_viewmodel.dart';
import 'package:nexo_future_app/ui/viewmodels/cadastro_oficina_viewmodel.dart';

import '../../apoio/autenticacao_falsa.dart';
import '../../apoio/perfis_falsos.dart';

void main() {
  final hoje = DateTime(2026, 10, 28);
  late AutenticacaoFalsa auth;
  late PerfisFalsos perfis;

  setUp(() {
    auth = AutenticacaoFalsa();
    perfis = PerfisFalsos();
  });

  group('CadastroEmpresaViewModel', () {
    late CadastroEmpresaViewModel viewModel;

    setUp(() {
      viewModel = CadastroEmpresaViewModel(
        CadastrarEmpresa(auth, perfis, relogio: () => hoje),
      );
    });

    DadosCadastroEmpresa dados({
      String cnpj = '11.222.333/0001-81',
      String email = 'rh@fozazul.com',
    }) => DadosCadastroEmpresa(
      nome: 'Estaleiro Foz Azul',
      cnpj: cnpj,
      recrutador: 'Marcos Pereira',
      email: email,
      senha: 'senha1234',
      cidade: 'Itajaí',
      aceitePolitica: true,
    );

    test('com dados válidos, cadastra e guarda o perfil', () async {
      final cadastrou = await viewModel.cadastrar(dados());

      expect(cadastrou, isTrue);
      expect(viewModel.perfil?.email, 'rh@fozazul.com');
      expect(perfis.empresas, hasLength(1));
      expect(viewModel.erros, isEmpty);
      expect(viewModel.carregando, isFalse);
    });

    test('mostra o carregamento enquanto cria a conta', () async {
      final estados = <bool>[];
      viewModel.addListener(() => estados.add(viewModel.carregando));

      await viewModel.cadastrar(dados());

      expect(estados, [true, false]);
    });

    test('com CNPJ inválido, mostra o erro no campo', () async {
      final cadastrou = await viewModel.cadastrar(dados(cnpj: '123'));

      expect(cadastrou, isFalse);
      expect(viewModel.erros[CampoCadastro.cnpj], 'Informe um CNPJ válido.');
      expect(perfis.empresas, isEmpty);
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

      final cadastrou = await viewModel.cadastrar(dados());

      expect(cadastrou, isFalse);
      expect(
        viewModel.erroGeral,
        'Não foi possível criar a conta agora. Confira sua internet e tente de novo.',
      );
    });

    test('uma nova tentativa limpa os erros anteriores', () async {
      await viewModel.cadastrar(dados(cnpj: '123'));
      await viewModel.cadastrar(dados());

      expect(viewModel.erros, isEmpty);
      expect(viewModel.erroGeral, isNull);
    });
  });

  group('CadastroOficinaViewModel', () {
    late CadastroOficinaViewModel viewModel;

    setUp(() {
      viewModel = CadastroOficinaViewModel(
        CadastrarOficina(auth, perfis, relogio: () => hoje),
      );
    });

    DadosCadastroOficina dados({
      String numeroAlvara = '',
      DateTime? validadeAlvara,
    }) => DadosCadastroOficina(
      nome: 'Oficina Escola Mãos do Porto',
      cnpj: '11.222.333/0001-81',
      gestor: 'Rita Moraes',
      email: 'contato@maosdoporto.com',
      senha: 'senha1234',
      cidade: 'Itajaí',
      numeroAlvara: numeroAlvara,
      validadeAlvara: validadeAlvara,
      aceitePolitica: true,
    );

    test('cadastra sem alvará e avisa que ainda não publica cursos', () async {
      final cadastrou = await viewModel.cadastrar(dados());

      expect(cadastrou, isTrue);
      expect(perfis.oficinas, hasLength(1));
      expect(viewModel.podePublicarCursos(hoje), isFalse);
    });

    test('cadastra com alvará em dia e já pode publicar cursos', () async {
      await viewModel.cadastrar(
        dados(
          numeroAlvara: 'AE-2026-0042',
          validadeAlvara: DateTime(2027, 3, 1),
        ),
      );

      expect(viewModel.perfil?.alvara?.numero, 'AE-2026-0042');
      expect(viewModel.podePublicarCursos(hoje), isTrue);
    });

    test('alvará incompleto aparece no campo do alvará', () async {
      final cadastrou = await viewModel.cadastrar(
        dados(numeroAlvara: 'AE-2026-0042'),
      );

      expect(cadastrou, isFalse);
      expect(
        viewModel.erros[CampoCadastro.alvara],
        'Informe a validade do alvará.',
      );
    });

    test('antes de cadastrar, não publica cursos', () {
      expect(viewModel.perfil, isNull);
      expect(viewModel.podePublicarCursos(hoje), isFalse);
    });
  });
}
