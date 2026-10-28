import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/domain/erros.dart';
import 'package:nexo_future_app/domain/models/cadastro.dart';
import 'package:nexo_future_app/domain/models/oficina.dart';
import 'package:nexo_future_app/domain/regras/alvara_oficina.dart';
import 'package:nexo_future_app/domain/regras/cadastro_oficina.dart';

import '../apoio/autenticacao_falsa.dart';
import '../apoio/perfis_falsos.dart';

void main() {
  final hoje = DateTime(2026, 10, 28);

  DadosCadastroOficina dados({
    String nome = 'Oficina Escola Mãos do Porto',
    String cnpj = '11.222.333/0001-81',
    String gestor = 'Rita Moraes',
    String email = 'contato@maosdoporto.com',
    String senha = 'senha1234',
    String cidade = 'Itajaí',
    String numeroAlvara = '',
    DateTime? validadeAlvara,
    bool aceitePolitica = true,
  }) => DadosCadastroOficina(
    nome: nome,
    cnpj: cnpj,
    gestor: gestor,
    email: email,
    senha: senha,
    cidade: cidade,
    numeroAlvara: numeroAlvara,
    validadeAlvara: validadeAlvara,
    aceitePolitica: aceitePolitica,
  );

  Map<CampoCadastro, String> validar(DadosCadastroOficina d) =>
      validarCadastroOficina(d, hoje: hoje);

  group('RF0002: cadastro da oficina, campos obrigatórios', () {
    test('dados completos, sem alvará, não têm erros', () {
      expect(validar(dados()), isEmpty);
    });

    test('dados completos, com alvará em dia, não têm erros', () {
      expect(
        validar(
          dados(
            numeroAlvara: 'AE-2026-0042',
            validadeAlvara: DateTime(2027, 3, 1),
          ),
        ),
        isEmpty,
      );
    });

    test('nome da oficina vazio é apontado', () {
      expect(
        validar(dados(nome: ''))[CampoCadastro.nome],
        'Informe o nome da oficina.',
      );
    });

    test('CNPJ inválido é apontado', () {
      expect(
        validar(dados(cnpj: '11.222.333/0001-82'))[CampoCadastro.cnpj],
        'Informe um CNPJ válido.',
      );
    });

    test('o gestor informa nome e sobrenome', () {
      expect(
        validar(dados(gestor: ''))[CampoCadastro.gestor],
        'Informe o nome de quem responde pela oficina.',
      );
      expect(
        validar(dados(gestor: 'Rita'))[CampoCadastro.gestor],
        'Informe nome e sobrenome.',
      );
    });

    test('e-mail, senha, cidade e política seguem as regras do cadastro', () {
      final erros = validar(
        dados(
          email: 'contato',
          senha: '123',
          cidade: 'Joinville',
          aceitePolitica: false,
        ),
      );

      expect(erros[CampoCadastro.email], 'Informe um e-mail válido.');
      expect(
        erros[CampoCadastro.senha],
        'A senha precisa ter pelo menos 8 caracteres.',
      );
      expect(erros[CampoCadastro.cidade], 'Escolha a cidade da oficina.');
      expect(
        erros[CampoCadastro.politica],
        'Aceite a Política de Privacidade para continuar.',
      );
    });
  });

  group('RF0002: alvará de ensino no cadastro', () {
    test('número sem validade pede a validade', () {
      expect(
        validar(dados(numeroAlvara: 'AE-2026-0042'))[CampoCadastro.alvara],
        'Informe a validade do alvará.',
      );
    });

    test('validade sem número pede o número', () {
      expect(
        validar(
          dados(validadeAlvara: DateTime(2027, 3, 1)),
        )[CampoCadastro.alvara],
        'Informe o número do alvará.',
      );
    });

    test('alvará já vencido é apontado', () {
      expect(
        validar(
          dados(
            numeroAlvara: 'AE-2025-0010',
            validadeAlvara: DateTime(2026, 10, 27),
          ),
        )[CampoCadastro.alvara],
        'Este alvará já venceu. Informe o alvará em dia ou deixe para enviar depois.',
      );
    });
  });

  group('Cadastrar oficina (RF0002, RF0016 e RN0003)', () {
    final agora = DateTime(2026, 10, 28, 9);
    late AutenticacaoFalsa auth;
    late PerfisFalsos perfis;
    late CadastrarOficina cadastrar;

    setUp(() {
      auth = AutenticacaoFalsa();
      perfis = PerfisFalsos();
      cadastrar = CadastrarOficina(auth, perfis, relogio: () => agora);
    });

    test('cria a conta, envia a confirmação e salva o perfil', () async {
      final perfil = await cadastrar(
        dados(
          nome: ' Oficina Escola Mãos do Porto ',
          email: ' Contato@MaosDoPorto.com ',
          numeroAlvara: ' AE-2026-0042 ',
          validadeAlvara: DateTime(2027, 3, 1),
        ),
      );

      expect(auth.contas.containsKey('contato@maosdoporto.com'), isTrue);
      expect(auth.confirmacoesEnviadas, ['contato@maosdoporto.com']);
      expect(perfis.oficinas[perfil.id], same(perfil));
      expect(perfil.nome, 'Oficina Escola Mãos do Porto');
      expect(perfil.cnpj, '11222333000181');
      expect(perfil.gestor, 'Rita Moraes');
      expect(perfil.email, 'contato@maosdoporto.com');
      expect(perfil.cidade, 'Itajaí');
      expect(perfil.alvara?.numero, 'AE-2026-0042');
      expect(perfil.alvara?.validade, DateTime(2027, 3, 1));
      expect(perfil.aceitePoliticaEm, agora);
    });

    test('oficina com alvará em dia já pode publicar curso', () async {
      final perfil = await cadastrar(
        dados(
          numeroAlvara: 'AE-2026-0042',
          validadeAlvara: DateTime(2027, 3, 1),
        ),
      );

      expect(podePublicarCurso(perfil.oficina, hoje: hoje), isTrue);
    });

    test('oficina cadastrada sem alvará não pode publicar curso', () async {
      final perfil = await cadastrar(dados());

      expect(perfil.alvara, isNull);
      expect(podePublicarCurso(perfil.oficina, hoje: hoje), isFalse);
    });

    test('com dados inválidos, não cria conta nem perfil', () async {
      await expectLater(
        cadastrar(dados(gestor: 'Rita')),
        throwsA(isA<CadastroInvalido>()),
      );
      expect(auth.contas.containsKey('contato@maosdoporto.com'), isFalse);
      expect(perfis.oficinas, isEmpty);
    });

    test('e-mail já cadastrado é recusado sem salvar perfil', () async {
      await expectLater(
        cadastrar(dados(email: 'ana@email.com')),
        throwsA(isA<EmailJaCadastrado>()),
      );
      expect(perfis.oficinas, isEmpty);
    });
  });

  test('o perfil vira a oficina usada na RN0003', () {
    final perfil = PerfilOficina(
      id: 'uid-rita',
      nome: 'Oficina Escola Mãos do Porto',
      cnpj: '11222333000181',
      gestor: 'Rita Moraes',
      email: 'contato@maosdoporto.com',
      cidade: 'Itajaí',
      alvara: Alvara(numero: 'AE-2026-0042', validade: DateTime(2027, 3, 1)),
      aceitePoliticaEm: hoje,
    );

    final oficina = perfil.oficina;
    expect(oficina.id, 'uid-rita');
    expect(oficina.nome, 'Oficina Escola Mãos do Porto');
    expect(oficina.cidade, 'Itajaí');
    expect(oficina.alvara, same(perfil.alvara));
  });
}
