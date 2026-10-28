import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/domain/erros.dart';
import 'package:nexo_future_app/domain/models/cadastro.dart';
import 'package:nexo_future_app/domain/models/empresa.dart';
import 'package:nexo_future_app/domain/regras/cadastro_empresa.dart';
import 'package:nexo_future_app/domain/regras/validacoes.dart';

import '../apoio/autenticacao_falsa.dart';
import '../apoio/perfis_falsos.dart';

void main() {
  // CNPJ fictício, com dígitos verificadores válidos.
  const cnpjFicticio = '11.222.333/0001-81';

  DadosCadastroEmpresa dados({
    String nome = 'Estaleiro Foz Azul',
    String cnpj = cnpjFicticio,
    String setor = 'Naval',
    String recrutador = 'Marcos Pereira',
    String email = 'rh@fozazul.com',
    String senha = 'senha1234',
    String cidade = 'Itajaí',
    bool aceitePolitica = true,
  }) => DadosCadastroEmpresa(
    nome: nome,
    cnpj: cnpj,
    setor: setor,
    recrutador: recrutador,
    email: email,
    senha: senha,
    cidade: cidade,
    aceitePolitica: aceitePolitica,
  );

  group('CNPJ', () {
    test('aceita CNPJ válido com ou sem pontuação', () {
      expect(cnpjValido(cnpjFicticio), isTrue);
      expect(cnpjValido('11222333000181'), isTrue);
    });

    test('recusa dígito verificador errado', () {
      expect(cnpjValido('11.222.333/0001-82'), isFalse);
    });

    test('recusa tamanho errado e números repetidos', () {
      expect(cnpjValido('1122233300018'), isFalse);
      expect(cnpjValido('11.111.111/1111-11'), isFalse);
      expect(cnpjValido(''), isFalse);
    });

    test('guarda só os dígitos', () {
      expect(somenteDigitos(cnpjFicticio), '11222333000181');
    });
  });

  group('RF0001: cadastro da empresa, campos obrigatórios', () {
    test('dados completos não têm erros', () {
      expect(validarCadastroEmpresa(dados()), isEmpty);
    });

    test('razão social vazia é apontada', () {
      expect(
        validarCadastroEmpresa(dados(nome: ' '))[CampoCadastro.nome],
        'Informe a razão social.',
      );
    });

    test('o setor precisa ser uma das áreas das vagas', () {
      expect(setoresEmpresa, [
        'Alimentos',
        'Construção Civil',
        'Logística',
        'Metalurgia',
        'Naval',
        'Turismo e Hotelaria',
      ]);
      expect(
        validarCadastroEmpresa(dados(setor: ''))[CampoCadastro.setor],
        'Escolha o setor da empresa.',
      );
      expect(
        validarCadastroEmpresa(dados(setor: 'Mineração'))[CampoCadastro.setor],
        'Escolha o setor da empresa.',
      );
    });

    test('CNPJ inválido é apontado', () {
      expect(
        validarCadastroEmpresa(dados(cnpj: '123'))[CampoCadastro.cnpj],
        'Informe um CNPJ válido.',
      );
    });

    test('o recrutador informa nome e sobrenome', () {
      expect(
        validarCadastroEmpresa(dados(recrutador: ''))[CampoCadastro.recrutador],
        'Informe o nome de quem faz o cadastro.',
      );
      expect(
        validarCadastroEmpresa(
          dados(recrutador: 'Marcos'),
        )[CampoCadastro.recrutador],
        'Informe nome e sobrenome.',
      );
    });

    test('e-mail, senha, cidade e política seguem as regras do cadastro', () {
      final erros = validarCadastroEmpresa(
        dados(
          email: 'rh@fozazul',
          senha: '1234567',
          cidade: 'Florianópolis',
          aceitePolitica: false,
        ),
      );

      expect(erros[CampoCadastro.email], 'Informe um e-mail válido.');
      expect(
        erros[CampoCadastro.senha],
        'A senha precisa ter pelo menos 8 caracteres.',
      );
      expect(erros[CampoCadastro.cidade], 'Escolha a cidade da empresa.');
      expect(
        erros[CampoCadastro.politica],
        'Aceite a Política de Privacidade para continuar.',
      );
    });

    test('todos os campos vazios são apontados de uma vez', () {
      final erros = validarCadastroEmpresa(
        dados(
          nome: '',
          cnpj: '',
          setor: '',
          recrutador: '',
          email: '',
          senha: '',
          cidade: '',
          aceitePolitica: false,
        ),
      );

      expect(erros.keys, hasLength(8));
    });
  });

  group('Cadastrar empresa (RF0001 e RF0016)', () {
    final agora = DateTime(2026, 10, 28, 10);
    late AutenticacaoFalsa auth;
    late PerfisFalsos perfis;
    late CadastrarEmpresa cadastrar;

    setUp(() {
      auth = AutenticacaoFalsa();
      perfis = PerfisFalsos();
      cadastrar = CadastrarEmpresa(auth, perfis, relogio: () => agora);
    });

    test('cria a conta, envia a confirmação e salva o perfil', () async {
      final perfil = await cadastrar(
        dados(nome: ' Estaleiro Foz Azul ', email: ' RH@FozAzul.com '),
      );

      expect(auth.contas.containsKey('rh@fozazul.com'), isTrue);
      expect(auth.confirmacoesEnviadas, ['rh@fozazul.com']);
      expect(perfis.empresas[perfil.id], same(perfil));
      expect(perfil.nome, 'Estaleiro Foz Azul');
      expect(perfil.cnpj, '11222333000181');
      expect(perfil.setor, 'Naval');
      expect(perfil.recrutador, 'Marcos Pereira');
      expect(perfil.email, 'rh@fozazul.com');
      expect(perfil.cidade, 'Itajaí');
      expect(perfil.aceitePoliticaEm, agora);
    });

    test('com dados inválidos, não cria conta nem perfil', () async {
      await expectLater(
        cadastrar(dados(cnpj: '11.222.333/0001-82')),
        throwsA(
          isA<CadastroInvalido>().having(
            (e) => e.erros[CampoCadastro.cnpj],
            'erro do CNPJ',
            'Informe um CNPJ válido.',
          ),
        ),
      );
      expect(auth.contas.containsKey('rh@fozazul.com'), isFalse);
      expect(perfis.empresas, isEmpty);
    });

    test('e-mail já cadastrado é recusado sem salvar perfil', () async {
      await expectLater(
        cadastrar(dados(email: 'ana@email.com')),
        throwsA(isA<EmailJaCadastrado>()),
      );
      expect(perfis.empresas, isEmpty);
    });
  });
}
