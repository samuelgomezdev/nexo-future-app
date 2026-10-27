import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/domain/erros.dart';
import 'package:nexo_future_app/domain/models/jovem.dart';
import 'package:nexo_future_app/domain/regras/cadastro_jovem.dart';

import '../apoio/autenticacao_falsa.dart';
import '../apoio/perfis_falsos.dart';

void main() {
  group('Cadastrar jovem (RF0003 e RF0016)', () {
    final agora = DateTime(2026, 10, 27, 15, 30);
    late AutenticacaoFalsa auth;
    late PerfisFalsos perfis;
    late CadastrarJovem cadastrar;

    setUp(() {
      auth = AutenticacaoFalsa();
      perfis = PerfisFalsos();
      cadastrar = CadastrarJovem(auth, perfis, relogio: () => agora);
    });

    DadosCadastroJovem dados({
      String email = 'carla@email.com',
      String nome = 'Carla Lima',
    }) => DadosCadastroJovem(
      nome: nome,
      email: email,
      senha: 'senha1234',
      cidade: 'Navegantes',
      dataNascimento: DateTime(2009, 3, 2),
      autorizacaoResponsavel: true,
      aceitePolitica: true,
    );

    test('cria a conta, envia a confirmação e salva o perfil', () async {
      final perfil = await cadastrar(
        dados(email: ' Carla@Email.com ', nome: ' Carla Lima '),
      );

      expect(auth.contas.containsKey('carla@email.com'), isTrue);
      expect(auth.confirmacoesEnviadas, ['carla@email.com']);
      expect(perfis.jovens[perfil.id], same(perfil));
      expect(perfil.nome, 'Carla Lima');
      expect(perfil.email, 'carla@email.com');
      expect(perfil.cidade, 'Navegantes');
      expect(perfil.dataNascimento, DateTime(2009, 3, 2));
      expect(perfil.autorizacaoResponsavel, isTrue);
    });

    test('guarda quando a Política de Privacidade foi aceita', () async {
      final perfil = await cadastrar(dados());

      expect(perfil.aceitePoliticaEm, agora);
    });

    test('com dados inválidos, não cria conta nem perfil', () async {
      await expectLater(
        cadastrar(dados(nome: 'Carla')),
        throwsA(
          isA<CadastroInvalido>().having(
            (e) => e.erros[CampoCadastro.nome],
            'erro do nome',
            'Informe nome e sobrenome.',
          ),
        ),
      );
      expect(auth.contas.containsKey('carla@email.com'), isFalse);
      expect(perfis.jovens, isEmpty);
    });

    test('e-mail já cadastrado é recusado sem salvar perfil', () async {
      await expectLater(
        cadastrar(dados(email: 'ana@email.com')),
        throwsA(isA<EmailJaCadastrado>()),
      );
      expect(perfis.jovens, isEmpty);
    });
  });
}
