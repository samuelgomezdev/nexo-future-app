import '../../domain/models/empresa.dart';
import '../../domain/regras/cadastro_empresa.dart';
import 'cadastro_viewmodel.dart';

/// Cadastro da empresa, feito pelo recrutador (RF0001).
class CadastroEmpresaViewModel
    extends CadastroViewModel<DadosCadastroEmpresa, PerfilEmpresa> {
  CadastroEmpresaViewModel(CadastrarEmpresa cadastrar) : super(cadastrar.call);
}
