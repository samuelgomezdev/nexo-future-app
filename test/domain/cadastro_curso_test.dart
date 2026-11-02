import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/domain/autenticacao.dart';
import 'package:nexo_future_app/domain/erros.dart';
import 'package:nexo_future_app/domain/models/cadastro.dart';
import 'package:nexo_future_app/domain/models/curso.dart';
import 'package:nexo_future_app/domain/models/oficina.dart';
import 'package:nexo_future_app/domain/regras/cadastro_curso.dart';

import '../apoio/vagas_falsas.dart';

void main() {
  final hoje = DateTime(2026, 11, 10);

  const vaga = Vaga(
    id: 'vaga-pintor',
    titulo: 'Pintor(a) naval',
    empresa: 'Estaleiro Foz Azul',
    area: 'Naval',
    cidade: 'Itajaí',
    qualificacao: 'Pintura de cascos.',
    situacao: SituacaoVaga.aberta,
    empresaId: 'uid-marcos',
    posicoes: 3,
  );

  Curso cursoVinculado(int i) =>
      Curso(id: 'c$i', nome: 'Curso $i', oficina: 'Oficina $i');

  DadosCurso dados({
    String nome = 'Pintura naval',
    Vaga? vagaLigada = vaga,
    int? cargaHoraria = 32,
    int? vagasTurma = 15,
    String descricao = 'Preparo de superfície e acabamento.',
  }) => DadosCurso(
    nome: nome,
    vaga: vagaLigada,
    cargaHoraria: cargaHoraria,
    vagasTurma: vagasTurma,
    descricao: descricao,
  );

  group('RF0005: validação do cadastro do curso', () {
    test('curso com os campos obrigatórios preenchidos não tem erros', () {
      expect(validarCurso(dados()), isEmpty);
      expect(validarCurso(dados(descricao: '')), isEmpty);
    });

    test('os campos obrigatórios vazios são apontados um a um', () {
      expect(
        validarCurso(
          dados(
            nome: '',
            vagaLigada: null,
            cargaHoraria: null,
            vagasTurma: null,
          ),
        ),
        {
          CampoCadastro.nome: 'Informe o nome do curso.',
          CampoCadastro.vaga: 'Escolha a vaga ligada ao curso.',
          CampoCadastro.cargaHoraria: 'Informe a carga horária.',
          CampoCadastro.vagasTurma: 'Informe as vagas na turma.',
        },
      );
    });

    test('carga horária e vagas na turma têm limites', () {
      expect(validarCurso(dados(cargaHoraria: 0, vagasTurma: 0)), {
        CampoCadastro.cargaHoraria: 'A carga horária vai de 1 a 1000 horas.',
        CampoCadastro.vagasTurma: 'As vagas na turma vão de 1 a 100.',
      });
    });

    test(
      'a vaga ligada precisa ter empresa: as vagas fictícias não servem',
      () {
        const doSeed = Vaga(
          id: 'vaga-01',
          titulo: 'Laminador',
          empresa: 'Estaleiro Foz Azul',
          area: 'Naval',
          cidade: 'Itajaí',
          qualificacao: 'Ensino fundamental completo',
          situacao: SituacaoVaga.aberta,
        );

        expect(aceitaNovosCursos(doSeed), isFalse);
        expect(
          validarCurso(dados(vagaLigada: doSeed)),
          containsPair(CampoCadastro.vaga, 'Escolha a vaga ligada ao curso.'),
        );
      },
    );

    test('vaga lotada não recebe cursos', () {
      final lotada = vaga.copiar(situacao: SituacaoVaga.lotada);

      expect(aceitaNovosCursos(lotada), isFalse);
      expect(
        validarCurso(dados(vagaLigada: lotada)),
        containsPair(
          CampoCadastro.vaga,
          'Esta vaga está lotada e não recebe cursos.',
        ),
      );
    });

    test('vaga com 5 cursos vinculados não recebe o 6º (RN0006)', () {
      final cheia = vaga.copiar(
        situacao: SituacaoVaga.aguardandoIngresso,
        cursos: [for (var i = 1; i <= 5; i++) cursoVinculado(i)],
      );

      expect(aceitaNovosCursos(cheia), isFalse);
      expect(
        validarCurso(dados(vagaLigada: cheia)),
        containsPair(
          CampoCadastro.vaga,
          'Esta vaga já tem 5 cursos vinculados.',
        ),
      );
    });

    test('vaga com 4 cursos ainda recebe', () {
      final quase = vaga.copiar(
        situacao: SituacaoVaga.aguardandoIngresso,
        cursos: [for (var i = 1; i <= 4; i++) cursoVinculado(i)],
      );

      expect(aceitaNovosCursos(quase), isTrue);
    });
  });

  group('RF0005, RN0003 e RN0001: a oficina publica o curso', () {
    late VagasFalsas vagas;
    late PublicarCurso publicar;

    PerfilOficina oficina({Alvara? alvara}) => PerfilOficina(
      id: 'uid-rita',
      nome: 'Oficina Escola Mãos do Porto',
      cnpj: '11222333000181',
      gestor: 'Rita Moraes',
      email: 'contato@maosdoporto.example.com',
      cidade: 'Itajaí',
      alvara: alvara,
      aceitePoliticaEm: DateTime(2026, 11, 1),
    );
    final comAlvara = oficina(
      alvara: Alvara(numero: 'AE-2026-0042', validade: DateTime(2027, 3, 1)),
    );
    const rita = Usuario(
      id: 'uid-rita',
      email: 'contato@maosdoporto.example.com',
      emailVerificado: true,
    );

    setUp(() {
      vagas = VagasFalsas([vaga]);
      publicar = PublicarCurso(vagas, relogio: () => hoje);
    });

    test(
      'com alvará em dia, o curso vai para a análise do recrutador',
      () async {
        final curso = await publicar(
          usuario: rita,
          oficina: comAlvara,
          dados: dados(nome: '  Pintura naval '),
        );

        expect(curso.situacao, SituacaoCurso.emAnalise);
        expect(curso.nome, 'Pintura naval');
        expect(curso.area, 'Naval');
        expect(curso.vagaId, 'vaga-pintor');
        expect(curso.vagaTitulo, 'Pintor(a) naval');
        expect(curso.empresaId, 'uid-marcos');
        expect(curso.empresa, 'Estaleiro Foz Azul');
        expect(curso.oficinaId, 'uid-rita');
        expect(curso.oficina, 'Oficina Escola Mãos do Porto');
        expect(curso.cargaHoraria, 32);
        expect(curso.vagasTurma, 15);
        expect(vagas.cursos[curso.id], same(curso));
      },
    );

    test('sem alvará, a oficina não publica curso (RN0003)', () async {
      await expectLater(
        publicar(usuario: rita, oficina: oficina(), dados: dados()),
        throwsA(isA<OficinaSemAlvara>()),
      );
      expect(vagas.cursos, isEmpty);
    });

    test('com o alvará vencido, também não publica (RN0003)', () async {
      final vencido = oficina(
        alvara: Alvara(numero: 'AE-2019-0001', validade: DateTime(2026, 11, 9)),
      );

      await expectLater(
        publicar(usuario: rita, oficina: vencido, dados: dados()),
        throwsA(isA<AlvaraVencido>()),
      );
      expect(vagas.cursos, isEmpty);
    });

    test('sem alvará, o curso pode ser salvo como rascunho', () async {
      final curso = await publicar(
        usuario: rita,
        oficina: oficina(),
        dados: dados(),
        rascunho: true,
      );

      expect(curso.situacao, SituacaoCurso.rascunho);
      expect(vagas.cursos[curso.id], same(curso));
    });

    test('o rascunho é publicado quando o alvará estiver em dia', () async {
      final rascunho = await publicar(
        usuario: rita,
        oficina: oficina(),
        dados: dados(),
        rascunho: true,
      );

      await expectLater(
        publicar.publicarRascunho(
          usuario: rita,
          oficina: oficina(),
          curso: rascunho,
        ),
        throwsA(isA<OficinaSemAlvara>()),
      );

      final publicado = await publicar.publicarRascunho(
        usuario: rita,
        oficina: comAlvara,
        curso: rascunho,
      );
      expect(publicado.situacao, SituacaoCurso.emAnalise);
      expect(vagas.cursos[rascunho.id]?.situacao, SituacaoCurso.emAnalise);
    });

    test('com e-mail não confirmado, a oficina não publica (RN0001)', () async {
      const naoConfirmada = Usuario(
        id: 'uid-rita',
        email: 'contato@maosdoporto.example.com',
        emailVerificado: false,
      );

      await expectLater(
        publicar(usuario: naoConfirmada, oficina: comAlvara, dados: dados()),
        throwsA(isA<EmailNaoVerificado>()),
      );
      expect(vagas.cursos, isEmpty);
    });

    test('ninguém publica curso no lugar de outra oficina', () async {
      const outra = Usuario(
        id: 'uid-outra',
        email: 'outra@example.com',
        emailVerificado: true,
      );

      await expectLater(
        publicar(usuario: outra, oficina: comAlvara, dados: dados()),
        throwsA(isA<AcaoNaoPermitida>()),
      );
    });

    test('com campos a corrigir, nada é salvo', () async {
      await expectLater(
        publicar(
          usuario: rita,
          oficina: comAlvara,
          dados: dados(nome: ''),
        ),
        throwsA(isA<CadastroInvalido>()),
      );
      expect(vagas.cursos, isEmpty);
    });
  });
}
