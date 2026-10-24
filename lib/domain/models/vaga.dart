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
}

class Curso {
  const Curso({required this.id, required this.nome, required this.oficina});

  final String id;
  final String nome;
  final String oficina;
}
