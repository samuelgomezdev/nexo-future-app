import '../../domain/autenticacao.dart';
import '../../domain/models/empresa.dart';
import '../../domain/models/vaga.dart';
import '../../domain/regras/cadastro_vaga.dart';
import 'publicacao_viewmodel.dart';

/// E2 do protótipo: a empresa publica uma vaga (RF0004).
class NovaVagaViewModel extends PublicacaoViewModel {
  NovaVagaViewModel(this._publicar);

  final PublicarVaga _publicar;

  Vaga? vaga;

  Future<bool> publicar({
    required Usuario usuario,
    required PerfilEmpresa empresa,
    required DadosVaga dados,
  }) => executar(() async {
    vaga = await _publicar(usuario: usuario, empresa: empresa, dados: dados);
  });
}
