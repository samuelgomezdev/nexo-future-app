import '../../domain/autenticacao.dart';
import '../../domain/models/curso.dart';
import '../../domain/models/oficina.dart';
import '../../domain/regras/cadastro_curso.dart';
import 'publicacao_viewmodel.dart';

/// O2 do protótipo: a oficina monta um curso para uma vaga (RF0005 e RF0015).
class NovoCursoViewModel extends PublicacaoViewModel {
  NovoCursoViewModel(this._publicar, this._vagas);

  final PublicarCurso _publicar;
  final RepositorioVagas _vagas;

  CursoOficina? curso;

  /// Vagas que ainda recebem cursos, em ordem alfabética.
  List<Vaga> vagasDisponiveis = const [];

  Future<void> carregarVagas() async {
    try {
      final todas = await _vagas.listarVagas();
      vagasDisponiveis = todas.where(aceitaNovosCursos).toList()
        ..sort((a, b) => a.titulo.compareTo(b.titulo));
    } on Exception {
      erroGeral = 'Não foi possível carregar as vagas. Confira sua internet e tente de novo.';
    }
    notifyListeners();
  }

  /// Sem o alvará em dia (RN0003), só o [rascunho] é aceito.
  Future<bool> publicar({
    required Usuario usuario,
    required PerfilOficina oficina,
    required DadosCurso dados,
    bool rascunho = false,
  }) => executar(() async {
    curso = await _publicar(
      usuario: usuario,
      oficina: oficina,
      dados: dados,
      rascunho: rascunho,
    );
  });
}
