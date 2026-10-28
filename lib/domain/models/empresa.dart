/// O que o recrutador preenche no cadastro da empresa.
class DadosCadastroEmpresa {
  const DadosCadastroEmpresa({
    required this.nome,
    required this.cnpj,
    required this.setor,
    required this.recrutador,
    required this.email,
    required this.senha,
    required this.cidade,
    required this.aceitePolitica,
  });

  /// Razão social.
  final String nome;
  final String cnpj;

  /// Uma das áreas das vagas, como Naval ou Logística.
  final String setor;

  /// Nome de quem faz o cadastro e responde pelas vagas.
  final String recrutador;
  final String email;
  final String senha;
  final String cidade;
  final bool aceitePolitica;
}

/// O que fica salvo da empresa. A senha fica só no Firebase Auth.
class PerfilEmpresa {
  const PerfilEmpresa({
    required this.id,
    required this.nome,
    required this.cnpj,
    required this.setor,
    required this.recrutador,
    required this.email,
    required this.cidade,
    required this.aceitePoliticaEm,
  });

  final String id;
  final String nome;

  /// Só os 14 dígitos, sem pontuação.
  final String cnpj;
  final String setor;
  final String recrutador;
  final String email;
  final String cidade;
  final DateTime aceitePoliticaEm;
}
