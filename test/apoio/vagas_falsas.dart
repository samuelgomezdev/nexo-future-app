import 'package:nexo_future_app/domain/models/curso.dart';
import 'package:nexo_future_app/domain/models/vaga.dart';

/// Repositório de vagas e cursos falso: simula o Firestore em memória.
class VagasFalsas implements RepositorioVagas {
  VagasFalsas([List<Vaga> iniciais = const []])
    : vagas = {for (final vaga in iniciais) vaga.id: vaga};

  final Map<String, Vaga> vagas;
  final cursos = <String, CursoOficina>{};
  var _contador = 0;

  /// Simula uma falha do banco (sem internet, servidor fora etc.).
  Exception? falhaInesperada;

  void _conferirFalha() {
    final falha = falhaInesperada;
    if (falha != null) throw falha;
  }

  @override
  String novoId() => 'id-${++_contador}';

  @override
  Future<List<Vaga>> listarVagas() async {
    _conferirFalha();
    return vagas.values.toList();
  }

  @override
  Future<Vaga?> buscarVaga(String id) async => vagas[id];

  @override
  Future<List<Vaga>> vagasDaEmpresa(String empresaId) async =>
      vagas.values.where((v) => v.empresaId == empresaId).toList();

  @override
  Future<void> salvarVaga(Vaga vaga) async {
    _conferirFalha();
    vagas[vaga.id] = vaga;
  }

  @override
  Future<void> salvarCurso(CursoOficina curso) async {
    _conferirFalha();
    cursos[curso.id] = curso;
  }

  @override
  Future<List<CursoOficina>> cursosDaOficina(String oficinaId) async =>
      cursos.values.where((c) => c.oficinaId == oficinaId).toList();

  @override
  Future<List<CursoOficina>> cursosParaAprovar(String empresaId) async =>
      cursos.values
          .where(
            (c) =>
                c.empresaId == empresaId &&
                c.situacao == SituacaoCurso.emAnalise,
          )
          .toList();

  @override
  Future<void> decidirCurso(CursoOficina curso, {Vaga? vaga}) async {
    _conferirFalha();
    cursos[curso.id] = curso;
    if (vaga != null) vagas[vaga.id] = vaga;
  }
}
