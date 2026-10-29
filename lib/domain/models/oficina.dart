import 'cadastro.dart';

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

/// O que o gestor preenche no cadastro da oficina.
class DadosCadastroOficina {
  const DadosCadastroOficina({
    required this.nome,
    required this.cnpj,
    required this.gestor,
    required this.email,
    required this.senha,
    required this.cidade,
    required this.numeroAlvara,
    required this.validadeAlvara,
    required this.aceitePolitica,
  });

  final String nome;
  final String cnpj;

  /// Nome de quem responde pela oficina (gestor ou professor).
  final String gestor;
  final String email;
  final String senha;
  final String cidade;

  /// O alvará pode ficar para depois; sem ele, a oficina não publica curso (RN0003).
  final String numeroAlvara;
  final DateTime? validadeAlvara;
  final bool aceitePolitica;
}

/// O que fica salvo da oficina. A senha fica só no Firebase Auth.
class PerfilOficina implements Perfil {
  const PerfilOficina({
    required this.id,
    required this.nome,
    required this.cnpj,
    required this.gestor,
    required this.email,
    required this.cidade,
    required this.alvara,
    required this.aceitePoliticaEm,
  });

  @override
  final String id;
  @override
  final String nome;

  /// Só os 14 dígitos, sem pontuação.
  final String cnpj;
  final String gestor;
  @override
  final String email;
  final String cidade;
  final Alvara? alvara;
  final DateTime aceitePoliticaEm;

  Oficina get oficina =>
      Oficina(id: id, nome: nome, cidade: cidade, alvara: alvara);
}
