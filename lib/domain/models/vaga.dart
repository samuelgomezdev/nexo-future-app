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
  });

  final String id;
  final String titulo;
  final String empresa;
  final String area;
  final String cidade;
  final String qualificacao;
  final SituacaoVaga situacao;
}
