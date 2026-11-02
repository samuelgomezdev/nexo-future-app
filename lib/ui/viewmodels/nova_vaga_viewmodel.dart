import '../../domain/autenticacao.dart';
import '../../domain/models/empresa.dart';
import '../../domain/models/curso.dart';
import '../../domain/regras/cadastro_vaga.dart';
import 'publicacao_viewmodel.dart';

/// E2 do protótipo: a empresa publica uma vaga (RF0004).
class NovaVagaViewModel extends PublicacaoViewModel {
  NovaVagaViewModel(this._publicar, [this._vagas]);

  final PublicarVaga _publicar;
  final RepositorioVagas? _vagas;

  Vaga? vaga;

  /// Cursos aprovados que o recrutador pode escolher como preferenciais.
  List<CursoOficina> cursosAprovados = const [];

  Future<void> carregarCursos() async {
    try {
      cursosAprovados = await _vagas?.cursosAprovados() ?? const [];
    } on Exception {
      cursosAprovados = const [];
    }
    notifyListeners();
  }

  /// Os cursos da [area], sem repetir e sem os já escolhidos.
  List<Curso> cursosDaArea(String? area, List<Curso> escolhidos) {
    final vistos = {for (final curso in escolhidos) curso.id};
    return [
      for (final curso in cursosAprovados)
        if (curso.area == area && vistos.add(curso.id)) curso.vinculo,
    ];
  }

  Future<bool> publicar({
    required Usuario usuario,
    required PerfilEmpresa empresa,
    required DadosVaga dados,
  }) => executar(() async {
    vaga = await _publicar(usuario: usuario, empresa: empresa, dados: dados);
  });
}
