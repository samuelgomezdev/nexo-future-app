import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/domain/autenticacao.dart';
import 'package:nexo_future_app/domain/erros.dart';
import 'package:nexo_future_app/domain/models/curso.dart';
import 'package:nexo_future_app/domain/models/empresa.dart';
import 'package:nexo_future_app/domain/regras/aprovacao_curso.dart';
import 'package:nexo_future_app/domain/regras/situacao_vaga.dart';

import '../apoio/vagas_falsas.dart';

void main() {
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

  CursoOficina curso({
    String id = 'curso-pintura',
    String vagaId = 'vaga-pintor',
    String empresaId = 'uid-marcos',
    SituacaoCurso situacao = SituacaoCurso.emAnalise,
  }) => CursoOficina(
    id: id,
    nome: 'Pintura naval',
    area: 'Naval',
    cargaHoraria: 32,
    vagasTurma: 15,
    descricao: 'Preparo de superfície e acabamento.',
    vagaId: vagaId,
    vagaTitulo: 'Pintor(a) naval',
    empresaId: empresaId,
    empresa: 'Estaleiro Foz Azul',
    oficinaId: 'uid-rita',
    oficina: 'Oficina Escola Mãos do Porto',
    situacao: situacao,
  );

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
  const marcos = Usuario(
    id: 'uid-marcos',
    email: 'rh@fozazul.example.com',
    emailVerificado: true,
  );

  late VagasFalsas vagas;
  late DecidirCurso decidir;

  setUp(() {
    vagas = VagasFalsas([vaga]);
    decidir = DecidirCurso(vagas);
  });

  group('RF0007 e RF0015: o recrutador aprova o curso proposto', () {
    test('ao aprovar, o curso é vinculado e a vaga passa a aceitar '
        'candidaturas', () async {
      final proposto = curso();
      vagas.cursos[proposto.id] = proposto;

      final atualizada = await decidir.aprovar(
        usuario: marcos,
        empresa: empresa,
        curso: proposto,
      );

      expect(atualizada.situacao, SituacaoVaga.aguardandoIngresso);
      expect(atualizada.cursos.map((c) => c.nome), ['Pintura naval']);
      expect(atualizada.cursos.single.oficina, 'Oficina Escola Mãos do Porto');
      expect(atualizada.cursos.single.cargaHoraria, 32);
      expect(vagas.vagas['vaga-pintor'], same(atualizada));
      expect(vagas.cursos['curso-pintura']?.situacao, SituacaoCurso.aprovado);
    });

    test(
      'RF0008: a vaga só aceita candidaturas depois do curso aprovado',
      () async {
        expect(
          () => garantirVagaDisponivel(vaga),
          throwsA(isA<VagaNaoDisponivel>()),
        );

        final atualizada = await decidir.aprovar(
          usuario: marcos,
          empresa: empresa,
          curso: curso(),
        );

        expect(() => garantirVagaDisponivel(atualizada), returnsNormally);
      },
    );

    test('o segundo curso aprovado se soma ao primeiro', () async {
      await decidir.aprovar(usuario: marcos, empresa: empresa, curso: curso());
      final atualizada = await decidir.aprovar(
        usuario: marcos,
        empresa: empresa,
        curso: curso(id: 'curso-nr35'),
      );

      expect(atualizada.cursos.map((c) => c.id), [
        'curso-pintura',
        'curso-nr35',
      ]);
      expect(atualizada.situacao, SituacaoVaga.aguardandoIngresso);
    });

    test('vaga lotada continua lotada ao aprovar curso', () async {
      vagas.vagas['vaga-pintor'] = vaga.copiar(situacao: SituacaoVaga.lotada);

      final atualizada = await decidir.aprovar(
        usuario: marcos,
        empresa: empresa,
        curso: curso(),
      );

      expect(atualizada.situacao, SituacaoVaga.lotada);
    });

    test('vaga com 5 cursos não aceita o 6º (RN0006)', () async {
      for (var i = 1; i <= 5; i++) {
        await decidir.aprovar(
          usuario: marcos,
          empresa: empresa,
          curso: curso(id: 'curso-$i'),
        );
      }

      await expectLater(
        decidir.aprovar(
          usuario: marcos,
          empresa: empresa,
          curso: curso(id: 'curso-6'),
        ),
        throwsA(isA<LimiteCursosAtingido>()),
      );
      expect(vagas.vagas['vaga-pintor']?.cursos, hasLength(5));
    });

    test('curso que não está em análise não é aprovado de novo', () async {
      await expectLater(
        decidir.aprovar(
          usuario: marcos,
          empresa: empresa,
          curso: curso(situacao: SituacaoCurso.rascunho),
        ),
        throwsA(isA<CursoJaDecidido>()),
      );
      await expectLater(
        decidir.aprovar(
          usuario: marcos,
          empresa: empresa,
          curso: curso(situacao: SituacaoCurso.aprovado),
        ),
        throwsA(isA<CursoJaDecidido>()),
      );
    });
  });

  group('O recrutador recusa o curso proposto', () {
    test('o curso fica recusado e a vaga não muda', () async {
      final recusado = await decidir.recusar(
        usuario: marcos,
        empresa: empresa,
        curso: curso(),
      );

      expect(recusado.situacao, SituacaoCurso.recusado);
      expect(vagas.cursos['curso-pintura']?.situacao, SituacaoCurso.recusado);
      expect(vagas.vagas['vaga-pintor'], same(vaga));
    });
  });

  group('Só a empresa dona da vaga decide', () {
    test('outra empresa não aprova curso de vaga que não é dela', () async {
      final outraEmpresa = PerfilEmpresa(
        id: 'uid-outra',
        nome: 'TransVale Logística',
        cnpj: '11222333000181',
        setor: 'Logística',
        recrutador: 'Paula Dias',
        email: 'rh@transvale.example.com',
        cidade: 'Itajaí',
        aceitePoliticaEm: DateTime(2026, 11, 1),
      );
      const paula = Usuario(
        id: 'uid-outra',
        email: 'rh@transvale.example.com',
        emailVerificado: true,
      );

      await expectLater(
        decidir.aprovar(usuario: paula, empresa: outraEmpresa, curso: curso()),
        throwsA(isA<AcaoNaoPermitida>()),
      );
      await expectLater(
        decidir.recusar(usuario: paula, empresa: outraEmpresa, curso: curso()),
        throwsA(isA<AcaoNaoPermitida>()),
      );
      expect(vagas.vagas['vaga-pintor'], same(vaga));
    });

    test('o curso que aponta para a empresa, mas para vaga de outra, é '
        'recusado pela regra', () async {
      vagas.vagas['vaga-alheia'] = const Vaga(
        id: 'vaga-alheia',
        titulo: 'Motorista CNH D',
        empresa: 'TransVale Logística',
        area: 'Logística',
        cidade: 'Itajaí',
        qualificacao: 'CNH D',
        situacao: SituacaoVaga.aberta,
        empresaId: 'uid-outra',
      );

      await expectLater(
        decidir.aprovar(
          usuario: marcos,
          empresa: empresa,
          curso: curso(vagaId: 'vaga-alheia'),
        ),
        throwsA(isA<AcaoNaoPermitida>()),
      );
    });

    test(
      'com e-mail não confirmado, o recrutador não decide (RN0001)',
      () async {
        const naoConfirmado = Usuario(
          id: 'uid-marcos',
          email: 'rh@fozazul.example.com',
          emailVerificado: false,
        );

        await expectLater(
          decidir.aprovar(
            usuario: naoConfirmado,
            empresa: empresa,
            curso: curso(),
          ),
          throwsA(isA<EmailNaoVerificado>()),
        );
      },
    );
  });
}
