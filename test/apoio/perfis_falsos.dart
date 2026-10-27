import 'package:nexo_future_app/domain/models/jovem.dart';

/// Repositório de perfis falso: simula o Firestore em memória.
class PerfisFalsos implements RepositorioPerfis {
  final jovens = <String, PerfilJovem>{};

  @override
  Future<void> salvarJovem(PerfilJovem perfil) async {
    jovens[perfil.id] = perfil;
  }
}
