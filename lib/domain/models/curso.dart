import 'vaga.dart';

export 'vaga.dart';

enum SituacaoCurso {
  /// Salvo pela oficina, ainda sem publicar (por exemplo, sem alvará: RN0003).
  rascunho,

  /// Publicado e aguardando a decisão do recrutador da vaga ligada.
  emAnalise,

  /// Aprovado pelo recrutador e vinculado à vaga (RF0007).
  aprovado,

  /// Recusado pelo recrutador; não aparece na vaga.
  recusado,
}

/// Curso que a oficina monta para preparar o jovem para uma vaga (RF0005).
class CursoOficina {
  const CursoOficina({
    required this.id,
    required this.nome,
    required this.area,
    required this.cargaHoraria,
    required this.vagasTurma,
    required this.descricao,
    required this.vagaId,
    required this.vagaTitulo,
    required this.empresaId,
    required this.empresa,
    required this.oficinaId,
    required this.oficina,
    required this.situacao,
  });

  final String id;
  final String nome;

  /// A mesma área da vaga ligada ao curso.
  final String area;

  /// Em horas.
  final int cargaHoraria;
  final int vagasTurma;
  final String descricao;

  /// Vaga para a qual a oficina propõe o curso (RF0015).
  final String vagaId;
  final String vagaTitulo;
  final String empresaId;
  final String empresa;
  final String oficinaId;
  final String oficina;
  final SituacaoCurso situacao;

  /// Como o curso aparece no detalhe da vaga depois de aprovado.
  Curso get vinculo =>
      Curso(id: id, nome: nome, oficina: oficina, cargaHoraria: cargaHoraria);

  CursoOficina copiar({SituacaoCurso? situacao}) => CursoOficina(
    id: id,
    nome: nome,
    area: area,
    cargaHoraria: cargaHoraria,
    vagasTurma: vagasTurma,
    descricao: descricao,
    vagaId: vagaId,
    vagaTitulo: vagaTitulo,
    empresaId: empresaId,
    empresa: empresa,
    oficinaId: oficinaId,
    oficina: oficina,
    situacao: situacao ?? this.situacao,
  );
}

/// Onde vagas e cursos são guardados: o Firestore no app, uma versão falsa nos testes.
abstract class RepositorioVagas {
  /// Identificador novo para uma vaga ou um curso.
  String novoId();

  /// Todas as vagas publicadas, para a pesquisa (aberta a visitantes: RN0007).
  Future<List<Vaga>> listarVagas();

  Future<Vaga?> buscarVaga(String id);

  Future<List<Vaga>> vagasDaEmpresa(String empresaId);

  Future<void> salvarVaga(Vaga vaga);

  Future<void> salvarCurso(CursoOficina curso);

  Future<List<CursoOficina>> cursosDaOficina(String oficinaId);

  /// Cursos já aprovados por algum recrutador, que podem ser escolhidos como
  /// preferenciais de outra vaga (RF0015).
  Future<List<CursoOficina>> cursosAprovados();

  /// Cursos em análise propostos para as vagas da empresa.
  Future<List<CursoOficina>> cursosParaAprovar(String empresaId);

  /// Grava a decisão do recrutador; ao aprovar, grava junto a vaga com o
  /// curso vinculado, numa operação só.
  Future<void> decidirCurso(CursoOficina curso, {Vaga? vaga});
}
