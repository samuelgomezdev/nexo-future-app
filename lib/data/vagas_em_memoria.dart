import '../domain/models/curso.dart';

/// Vagas e cursos guardados só no aparelho: usado quando o app roda sem o
/// Firebase (demonstração) e como base do repositório falso dos testes.
class VagasEmMemoria implements RepositorioVagas {
  VagasEmMemoria([List<Vaga> iniciais = const []])
    : vagas = {for (final vaga in iniciais) vaga.id: vaga};

  final Map<String, Vaga> vagas;
  final cursos = <String, CursoOficina>{};
  var _contador = 0;

  @override
  String novoId() => 'id-${++_contador}';

  /// As mais novas primeiro, como no Firestore.
  @override
  Future<List<Vaga>> listarVagas() async =>
      vagas.values.toList().reversed.toList();

  @override
  Future<Vaga?> buscarVaga(String id) async => vagas[id];

  @override
  Future<List<Vaga>> vagasDaEmpresa(String empresaId) async =>
      vagas.values.where((v) => v.empresaId == empresaId).toList();

  @override
  Future<void> salvarVaga(Vaga vaga) async => vagas[vaga.id] = vaga;

  @override
  Future<void> salvarCurso(CursoOficina curso) async =>
      cursos[curso.id] = curso;

  @override
  Future<List<CursoOficina>> cursosDaOficina(String oficinaId) async =>
      cursos.values.where((c) => c.oficinaId == oficinaId).toList();

  @override
  Future<List<CursoOficina>> cursosAprovados() async =>
      cursos.values.where((c) => c.situacao == SituacaoCurso.aprovado).toList();

  @override
  Future<List<CursoOficina>> cursosParaAprovar(String empresaId) async => cursos
      .values
      .where(
        (c) =>
            c.empresaId == empresaId && c.situacao == SituacaoCurso.emAnalise,
      )
      .toList();

  @override
  Future<void> decidirCurso(CursoOficina curso, {Vaga? vaga}) async {
    cursos[curso.id] = curso;
    if (vaga != null) vagas[vaga.id] = vaga;
  }
}
