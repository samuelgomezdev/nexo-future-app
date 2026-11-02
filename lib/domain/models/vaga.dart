enum SituacaoVaga {
  /// Ainda sem curso aprovado pelo recrutador.
  aberta,

  /// O recrutador já aprovou pelo menos um curso; aceita candidaturas.
  aguardandoIngresso,

  /// Todas as posições da vaga já foram preenchidas.
  lotada,
}

class Vaga {
  const Vaga({
    required this.id,
    required this.titulo,
    required this.empresa,
    required this.area,
    required this.cidade,
    required this.qualificacao,
    required this.situacao,
    this.cursos = const [],
    this.empresaId = '',
    this.posicoes = 1,
    this.candidaturas = 0,
  });

  final String id;
  final String titulo;
  final String empresa;
  final String area;
  final String cidade;
  final String qualificacao;
  final SituacaoVaga situacao;

  /// Cursos preferenciais aprovados pelo recrutador (RN0006: no máximo 5).
  final List<Curso> cursos;

  /// Conta da empresa que publicou a vaga; vazio nas vagas fictícias do seed.
  final String empresaId;

  /// Quantas pessoas a vaga contrata.
  final int posicoes;

  /// Candidaturas ativas; quando chegam às posições, a vaga lota.
  final int candidaturas;

  Vaga copiar({
    SituacaoVaga? situacao,
    List<Curso>? cursos,
    int? candidaturas,
  }) => Vaga(
    id: id,
    titulo: titulo,
    empresa: empresa,
    area: area,
    cidade: cidade,
    qualificacao: qualificacao,
    situacao: situacao ?? this.situacao,
    cursos: cursos ?? this.cursos,
    empresaId: empresaId,
    posicoes: posicoes,
    candidaturas: candidaturas ?? this.candidaturas,
  );
}

class Curso {
  const Curso({
    required this.id,
    required this.nome,
    required this.oficina,
    this.cargaHoraria = 0,
  });

  final String id;
  final String nome;
  final String oficina;

  /// Em horas; 0 quando não informada (cursos fictícios do seed).
  final int cargaHoraria;
}
