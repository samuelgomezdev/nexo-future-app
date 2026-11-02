import '../domain/models/curso.dart';

// Conversão entre os modelos e os documentos do Firestore, sem depender do
// Firebase (o FirestoreVagas acrescenta o criadoEm na hora de gravar).

Map<String, Object?> _cursoVinculadoParaMapa(Curso curso) => {
  'id': curso.id,
  'nome': curso.nome,
  'oficina': curso.oficina,
  'cargaHoraria': curso.cargaHoraria,
};

Map<String, Object?> vagaParaMapa(Vaga vaga) => {
  'titulo': vaga.titulo,
  'empresa': vaga.empresa,
  'empresaId': vaga.empresaId,
  'area': vaga.area,
  'cidade': vaga.cidade,
  'qualificacao': vaga.qualificacao,
  'posicoes': vaga.posicoes,
  'situacao': vaga.situacao.name,
  'cursos': [for (final curso in vaga.cursos) _cursoVinculadoParaMapa(curso)],
};

Vaga vagaDoMapa(String id, Map<String, Object?> dados) => Vaga(
  id: id,
  titulo: dados['titulo'] as String,
  empresa: dados['empresa'] as String,
  empresaId: dados['empresaId'] as String,
  area: dados['area'] as String,
  cidade: dados['cidade'] as String,
  qualificacao: dados['qualificacao'] as String,
  posicoes: (dados['posicoes'] as num).toInt(),
  situacao: SituacaoVaga.values.byName(dados['situacao'] as String),
  cursos: [
    for (final curso in (dados['cursos'] as List?) ?? const [])
      Curso(
        id: curso['id'] as String,
        nome: curso['nome'] as String,
        oficina: curso['oficina'] as String,
        cargaHoraria: (curso['cargaHoraria'] as num).toInt(),
      ),
  ],
);

Map<String, Object?> cursoParaMapa(CursoOficina curso) => {
  'nome': curso.nome,
  'area': curso.area,
  'cargaHoraria': curso.cargaHoraria,
  'vagasTurma': curso.vagasTurma,
  'descricao': curso.descricao,
  'vagaId': curso.vagaId,
  'vagaTitulo': curso.vagaTitulo,
  'empresaId': curso.empresaId,
  'empresa': curso.empresa,
  'oficinaId': curso.oficinaId,
  'oficina': curso.oficina,
  'situacao': curso.situacao.name,
};

CursoOficina cursoDoMapa(String id, Map<String, Object?> dados) => CursoOficina(
  id: id,
  nome: dados['nome'] as String,
  area: dados['area'] as String,
  cargaHoraria: (dados['cargaHoraria'] as num).toInt(),
  vagasTurma: (dados['vagasTurma'] as num).toInt(),
  descricao: dados['descricao'] as String,
  vagaId: dados['vagaId'] as String,
  vagaTitulo: dados['vagaTitulo'] as String,
  empresaId: dados['empresaId'] as String,
  empresa: dados['empresa'] as String,
  oficinaId: dados['oficinaId'] as String,
  oficina: dados['oficina'] as String,
  situacao: SituacaoCurso.values.byName(dados['situacao'] as String),
);
