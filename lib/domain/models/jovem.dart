/// Campos do cadastro do jovem, para apontar o erro no lugar certo.
enum CampoCadastro {
  nome,
  email,
  senha,
  cidade,
  nascimento,
  responsavel,
  politica,
}

/// O que o jovem preenche no cadastro.
class DadosCadastroJovem {
  const DadosCadastroJovem({
    required this.nome,
    required this.email,
    required this.senha,
    required this.cidade,
    required this.dataNascimento,
    required this.autorizacaoResponsavel,
    required this.aceitePolitica,
  });

  final String nome;
  final String email;
  final String senha;
  final String cidade;
  final DateTime? dataNascimento;

  /// Exigida de quem tem de 12 a 17 anos (LGPD, art. 14).
  final bool autorizacaoResponsavel;
  final bool aceitePolitica;
}

/// O que fica salvo do jovem. A senha fica só no Firebase Auth.
class PerfilJovem {
  const PerfilJovem({
    required this.id,
    required this.nome,
    required this.email,
    required this.cidade,
    required this.dataNascimento,
    required this.autorizacaoResponsavel,
    required this.aceitePoliticaEm,
  });

  final String id;
  final String nome;
  final String email;
  final String cidade;
  final DateTime dataNascimento;
  final bool autorizacaoResponsavel;
  final DateTime aceitePoliticaEm;
}

/// Onde os perfis são guardados: o Firestore no app, uma versão falsa nos testes.
abstract class RepositorioPerfis {
  Future<void> salvarJovem(PerfilJovem perfil);
}
