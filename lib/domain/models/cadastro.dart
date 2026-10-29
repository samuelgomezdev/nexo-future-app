import 'empresa.dart';
import 'jovem.dart';
import 'oficina.dart';

/// Campos dos cadastros, para apontar o erro no lugar certo.
enum CampoCadastro {
  nome,
  email,
  senha,
  cidade,
  nascimento,
  responsavel,
  politica,
  cnpj,
  setor,
  recrutador,
  gestor,
  alvara,
}

/// Lançada quando o cadastro tem campos a corrigir.
class CadastroInvalido implements Exception {
  const CadastroInvalido(this.erros);

  final Map<CampoCadastro, String> erros;

  @override
  String toString() => erros.values.join('\n');
}

/// O que todo perfil tem, seja de jovem, empresa ou oficina.
abstract interface class Perfil {
  String get id;
  String get nome;
  String get email;
}

/// Onde os perfis são guardados: o Firestore no app, uma versão falsa nos testes.
abstract class RepositorioPerfis {
  Future<void> salvarJovem(PerfilJovem perfil);

  Future<void> salvarEmpresa(PerfilEmpresa perfil);

  Future<void> salvarOficina(PerfilOficina perfil);

  /// O perfil de quem entrou; null quando a conta não tem perfil salvo.
  Future<Perfil?> buscarPerfil(String id);
}
