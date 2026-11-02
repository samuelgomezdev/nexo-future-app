import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/domain/autenticacao.dart';
import 'package:nexo_future_app/domain/erros.dart';
import 'package:nexo_future_app/domain/models/cadastro.dart';
import 'package:nexo_future_app/domain/models/empresa.dart';
import 'package:nexo_future_app/domain/models/vaga.dart';
import 'package:nexo_future_app/domain/regras/cadastro_vaga.dart';

import '../apoio/vagas_falsas.dart';

void main() {
  const dadosValidos = DadosVaga(
    titulo: 'Pintor(a) naval',
    area: 'Naval',
    posicoes: 3,
    cidade: 'Itajaí',
    qualificacao: 'Preparo de superfície e pintura de cascos.',
  );

  DadosVaga dados({
    String? titulo,
    String? area,
    int? posicoes,
    String? cidade,
    String? qualificacao,
  }) => DadosVaga(
    titulo: titulo ?? dadosValidos.titulo,
    area: area ?? dadosValidos.area,
    posicoes: posicoes ?? dadosValidos.posicoes,
    cidade: cidade ?? dadosValidos.cidade,
    qualificacao: qualificacao ?? dadosValidos.qualificacao,
  );

  group('RF0004: validação do cadastro da vaga', () {
    test('vaga com todos os campos preenchidos não tem erros', () {
      expect(validarVaga(dadosValidos), isEmpty);
    });

    test('os campos obrigatórios vazios são apontados um a um', () {
      const vazia = DadosVaga(
        titulo: ' ',
        area: '',
        posicoes: null,
        cidade: '',
        qualificacao: '',
      );

      expect(validarVaga(vazia), {
        CampoCadastro.titulo: 'Informe o cargo da vaga.',
        CampoCadastro.area: 'Escolha a área da vaga.',
        CampoCadastro.posicoes: 'Informe quantas pessoas a vaga contrata.',
        CampoCadastro.cidade: 'Escolha a cidade da vaga.',
        CampoCadastro.qualificacao: 'Informe a qualificação exigida.',
      });
    });

    test('a área é uma das áreas das vagas', () {
      expect(
        validarVaga(dados(area: 'Astronomia')),
        containsPair(CampoCadastro.area, 'Escolha a área da vaga.'),
      );
    });

    test('a cidade é uma das cidades da AMFRI', () {
      expect(
        validarVaga(dados(cidade: 'Curitiba')),
        containsPair(CampoCadastro.cidade, 'Escolha a cidade da vaga.'),
      );
    });

    test('as posições vão de 1 a 100', () {
      const erro = 'As posições vão de 1 a $limitePosicoesVaga.';
      expect(
        validarVaga(dados(posicoes: 0)),
        containsPair(CampoCadastro.posicoes, erro),
      );
      expect(
        validarVaga(dados(posicoes: 101)),
        containsPair(CampoCadastro.posicoes, erro),
      );
      expect(validarVaga(dados(posicoes: 1)), isEmpty);
      expect(validarVaga(dados(posicoes: 100)), isEmpty);
    });

    test('o cargo tem no máximo 80 letras', () {
      expect(
        validarVaga(dados(titulo: 'A' * 81)),
        containsPair(
          CampoCadastro.titulo,
          'Use no máximo 80 caracteres no cargo.',
        ),
      );
    });
  });

  group('RF0004 e RN0001: a empresa publica a vaga', () {
    late VagasFalsas vagas;
    late PublicarVaga publicar;

    final empresa = PerfilEmpresa(
      id: 'uid-marcos',
      nome: 'Estaleiro Foz Azul',
      cnpj: '11222333000181',
      setor: 'Naval',
      recrutador: 'Marcos Pereira',
      email: 'rh@fozazul.example.com',
      cidade: 'Itajaí',
      aceitePoliticaEm: DateTime(2026, 11, 1),
    );
    const confirmado = Usuario(
      id: 'uid-marcos',
      email: 'rh@fozazul.example.com',
      emailVerificado: true,
    );

    setUp(() {
      vagas = VagasFalsas();
      publicar = PublicarVaga(vagas);
    });

    test('a vaga nasce aberta, sem cursos, e fica salva', () async {
      final vaga = await publicar(
        usuario: confirmado,
        empresa: empresa,
        dados: dados(titulo: '  Pintor(a) naval  '),
      );

      expect(vaga.situacao, SituacaoVaga.aberta);
      expect(vaga.cursos, isEmpty);
      expect(vaga.titulo, 'Pintor(a) naval');
      expect(vaga.empresa, 'Estaleiro Foz Azul');
      expect(vaga.empresaId, 'uid-marcos');
      expect(vaga.posicoes, 3);
      expect(vagas.vagas[vaga.id], same(vaga));
    });

    test('com e-mail não confirmado, a empresa não publica (RN0001)', () async {
      const naoConfirmado = Usuario(
        id: 'uid-marcos',
        email: 'rh@fozazul.example.com',
        emailVerificado: false,
      );

      await expectLater(
        publicar(usuario: naoConfirmado, empresa: empresa, dados: dadosValidos),
        throwsA(isA<EmailNaoVerificado>()),
      );
      expect(vagas.vagas, isEmpty);
    });

    test('ninguém publica vaga no lugar de outra empresa', () async {
      const outro = Usuario(
        id: 'uid-outro',
        email: 'outro@example.com',
        emailVerificado: true,
      );

      await expectLater(
        publicar(usuario: outro, empresa: empresa, dados: dadosValidos),
        throwsA(isA<AcaoNaoPermitida>()),
      );
      expect(vagas.vagas, isEmpty);
    });

    test('com campos a corrigir, nada é salvo', () async {
      await expectLater(
        publicar(
          usuario: confirmado,
          empresa: empresa,
          dados: dados(titulo: ''),
        ),
        throwsA(
          isA<CadastroInvalido>().having(
            (e) => e.erros.keys,
            'campos',
            [CampoCadastro.titulo],
          ),
        ),
      );
      expect(vagas.vagas, isEmpty);
    });
  });
}
