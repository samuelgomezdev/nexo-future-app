import 'package:nexo_future_app/domain/models/empresa.dart';
import 'package:nexo_future_app/domain/models/jovem.dart';
import 'package:nexo_future_app/domain/models/oficina.dart';

/// Repositório de perfis falso: simula o Firestore em memória.
class PerfisFalsos implements RepositorioPerfis {
  final jovens = <String, PerfilJovem>{};
  final empresas = <String, PerfilEmpresa>{};
  final oficinas = <String, PerfilOficina>{};

  @override
  Future<void> salvarJovem(PerfilJovem perfil) async {
    jovens[perfil.id] = perfil;
  }

  @override
  Future<void> salvarEmpresa(PerfilEmpresa perfil) async {
    empresas[perfil.id] = perfil;
  }

  @override
  Future<void> salvarOficina(PerfilOficina perfil) async {
    oficinas[perfil.id] = perfil;
  }
}
