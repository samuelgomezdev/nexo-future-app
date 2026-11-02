import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/data/mapa_vagas.dart';
import 'package:nexo_future_app/domain/models/curso.dart';

void main() {
  group('Vaga no Firestore', () {
    const vaga = Vaga(
      id: 'abc123',
      titulo: 'Pintor(a) naval',
      empresa: 'Estaleiro Foz Azul',
      area: 'Naval',
      cidade: 'Itajaí',
      qualificacao: 'Pintura de cascos.',
      situacao: SituacaoVaga.aguardandoIngresso,
      empresaId: 'uid-marcos',
      posicoes: 3,
      cursos: [
        Curso(
          id: 'curso-1',
          nome: 'Pintura naval',
          oficina: 'Oficina Escola Mãos do Porto',
          cargaHoraria: 32,
        ),
      ],
    );

    test('a vaga vira um documento só com os campos públicos', () {
      expect(vagaParaMapa(vaga), {
        'titulo': 'Pintor(a) naval',
        'empresa': 'Estaleiro Foz Azul',
        'empresaId': 'uid-marcos',
        'area': 'Naval',
        'cidade': 'Itajaí',
        'qualificacao': 'Pintura de cascos.',
        'posicoes': 3,
        'situacao': 'aguardandoIngresso',
        'cursos': [
          {
            'id': 'curso-1',
            'nome': 'Pintura naval',
            'oficina': 'Oficina Escola Mãos do Porto',
            'cargaHoraria': 32,
          },
        ],
      });
    });

    test('o documento volta a ser a mesma vaga', () {
      final lida = vagaDoMapa('abc123', {
        ...vagaParaMapa(vaga),
        'criadoEm': DateTime(2026, 11, 10),
      });

      expect(lida.id, 'abc123');
      expect(lida.titulo, 'Pintor(a) naval');
      expect(lida.empresaId, 'uid-marcos');
      expect(lida.posicoes, 3);
      expect(lida.situacao, SituacaoVaga.aguardandoIngresso);
      expect(lida.cursos.single.nome, 'Pintura naval');
      expect(lida.cursos.single.cargaHoraria, 32);
      expect(vagaParaMapa(lida), vagaParaMapa(vaga));
    });

    test('documento sem cursos vira vaga sem cursos', () {
      final semCursos = {...vagaParaMapa(vaga)}..remove('cursos');

      expect(vagaDoMapa('abc123', semCursos).cursos, isEmpty);
    });
  });

  group('Curso no Firestore', () {
    const curso = CursoOficina(
      id: 'curso-1',
      nome: 'Pintura naval',
      area: 'Naval',
      cargaHoraria: 32,
      vagasTurma: 15,
      descricao: 'Preparo de superfície e acabamento.',
      vagaId: 'abc123',
      vagaTitulo: 'Pintor(a) naval',
      empresaId: 'uid-marcos',
      empresa: 'Estaleiro Foz Azul',
      oficinaId: 'uid-rita',
      oficina: 'Oficina Escola Mãos do Porto',
      situacao: SituacaoCurso.emAnalise,
    );

    test('o curso vira um documento e volta igual', () {
      final mapa = cursoParaMapa(curso);

      expect(mapa['situacao'], 'emAnalise');
      expect(mapa['oficinaId'], 'uid-rita');
      expect(mapa.containsKey('id'), isFalse);

      final lido = cursoDoMapa('curso-1', mapa);
      expect(lido.id, 'curso-1');
      expect(lido.situacao, SituacaoCurso.emAnalise);
      expect(cursoParaMapa(lido), mapa);
    });
  });
}
