import '../../domain/models/oficina.dart';
import '../../domain/regras/alvara_oficina.dart';
import '../../domain/regras/cadastro_oficina.dart';
import 'cadastro_viewmodel.dart';

/// Cadastro da oficina, feito pelo gestor (RF0002).
class CadastroOficinaViewModel
    extends CadastroViewModel<DadosCadastroOficina, PerfilOficina> {
  CadastroOficinaViewModel(CadastrarOficina cadastrar) : super(cadastrar.call);

  /// RN0003: sem o alvará em dia, a oficina ainda não publica cursos.
  bool podePublicarCursos(DateTime hoje) {
    final perfil = this.perfil;
    return perfil != null && podePublicarCurso(perfil.oficina, hoje: hoje);
  }
}
