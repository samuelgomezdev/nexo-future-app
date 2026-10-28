/// Alvará de ensino que a oficina apresenta para publicar cursos (RN0003).
class Alvara {
  const Alvara({required this.numero, required this.validade});

  final String numero;
  final DateTime validade;
}

/// Oficina profissionalizante que oferece os cursos.
class Oficina {
  const Oficina({
    required this.id,
    required this.nome,
    required this.cidade,
    this.alvara,
  });

  final String id;
  final String nome;
  final String cidade;

  /// Nulo enquanto a oficina não apresentou o alvará.
  final Alvara? alvara;
}
