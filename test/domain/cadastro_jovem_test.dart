import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/domain/models/jovem.dart';
import 'package:nexo_future_app/domain/regras/cadastro_jovem.dart';

void main() {
  final hoje = DateTime(2026, 10, 27);

  DadosCadastroJovem dados({
    String nome = 'Ana Souza',
    String email = 'ana@email.com',
    String senha = 'senha1234',
    String cidade = 'Itajaí',
    DateTime? nascimento,
    bool semNascimento = false,
    bool autorizacaoResponsavel = false,
    bool aceitePolitica = true,
  }) => DadosCadastroJovem(
    nome: nome,
    email: email,
    senha: senha,
    cidade: cidade,
    dataNascimento: semNascimento
        ? null
        : (nascimento ?? DateTime(2000, 5, 10)),
    autorizacaoResponsavel: autorizacaoResponsavel,
    aceitePolitica: aceitePolitica,
  );

  Map<CampoCadastro, String> validar(DadosCadastroJovem d) =>
      validarCadastroJovem(d, hoje: hoje);

  group('Cadastro do jovem: campos obrigatórios', () {
    test('dados completos de um adulto não têm erros', () {
      expect(validar(dados()), isEmpty);
    });

    test('nome vazio pede o nome completo', () {
      expect(
        validar(dados(nome: '  '))[CampoCadastro.nome],
        'Informe seu nome completo.',
      );
    });

    test('só o primeiro nome pede também o sobrenome', () {
      expect(
        validar(dados(nome: 'Ana'))[CampoCadastro.nome],
        'Informe nome e sobrenome.',
      );
    });

    test('e-mail sem formato válido é recusado', () {
      expect(
        validar(dados(email: 'ana@email'))[CampoCadastro.email],
        'Informe um e-mail válido.',
      );
    });

    test('senha com menos de 8 caracteres é recusada', () {
      expect(
        validar(dados(senha: '1234567'))[CampoCadastro.senha],
        'A senha precisa ter pelo menos 8 caracteres.',
      );
    });

    test('cidade precisa ser uma das cidades da AMFRI', () {
      expect(
        validar(dados(cidade: ''))[CampoCadastro.cidade],
        'Escolha sua cidade.',
      );
      expect(
        validar(dados(cidade: 'Florianópolis'))[CampoCadastro.cidade],
        'Escolha sua cidade.',
      );
    });

    test('as cidades são os 11 municípios da AMFRI', () {
      expect(cidadesAmfri, hasLength(11));
      expect(cidadesAmfri, containsAll(['Itajaí', 'Navegantes', 'Itapema']));
    });

    test('sem data de nascimento, pede a data', () {
      expect(
        validar(dados(semNascimento: true))[CampoCadastro.nascimento],
        'Informe sua data de nascimento.',
      );
    });

    test('data de nascimento no futuro é recusada', () {
      expect(
        validar(
          dados(nascimento: DateTime(2027, 1, 1)),
        )[CampoCadastro.nascimento],
        'Data de nascimento inválida.',
      );
    });
  });

  group('Cadastro do jovem: idade e responsável (LGPD, art. 14)', () {
    test('a idade só conta depois do aniversário', () {
      expect(idadeEm(DateTime(2008, 10, 27), hoje), 18);
      expect(idadeEm(DateTime(2008, 10, 28), hoje), 17);
    });

    test('menor de 12 anos não pode se cadastrar', () {
      expect(
        validar(
          dados(nascimento: DateTime(2014, 10, 28)),
        )[CampoCadastro.nascimento],
        'O Nexo Future é para quem tem 12 anos ou mais.',
      );
    });

    test('com 12 anos, precisa da autorização do responsável', () {
      final d = dados(nascimento: DateTime(2014, 10, 27));

      expect(
        validar(d)[CampoCadastro.responsavel],
        'Confirme que seu responsável autorizou o cadastro.',
      );
      expect(
        validar(
          dados(
            nascimento: DateTime(2014, 10, 27),
            autorizacaoResponsavel: true,
          ),
        ),
        isEmpty,
      );
    });

    test('com 17 anos, ainda precisa da autorização', () {
      expect(
        validar(
          dados(nascimento: DateTime(2008, 10, 28)),
        )[CampoCadastro.responsavel],
        isNotNull,
      );
    });

    test('com 18 anos, não precisa da autorização', () {
      expect(validar(dados(nascimento: DateTime(2008, 10, 27))), isEmpty);
    });

    test('sem aceitar a Política de Privacidade, não cadastra', () {
      expect(
        validar(dados(aceitePolitica: false))[CampoCadastro.politica],
        'Aceite a Política de Privacidade para continuar.',
      );
    });
  });
}
