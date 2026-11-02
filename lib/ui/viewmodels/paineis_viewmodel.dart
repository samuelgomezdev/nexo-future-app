import '../../domain/autenticacao.dart';
import '../../domain/models/curso.dart';
import '../../domain/models/empresa.dart';
import '../../domain/models/oficina.dart';
import '../../domain/regras/aprovacao_curso.dart';
import '../../domain/regras/cadastro_curso.dart';
import 'publicacao_viewmodel.dart';

const _erroCarregar =
    'Não foi possível carregar agora. Confira sua internet e tente de novo.';

/// E1 e E3 do protótipo: as vagas da empresa e os cursos para aprovar.
class PainelEmpresaViewModel extends PublicacaoViewModel {
  PainelEmpresaViewModel(this._vagas, this._decidir);

  final RepositorioVagas _vagas;
  final DecidirCurso _decidir;

  List<Vaga> vagas = const [];
  List<CursoOficina> paraAprovar = const [];

  int get vagasAbertas =>
      vagas.where((v) => v.situacao != SituacaoVaga.lotada).length;

  int get totalCandidaturas =>
      vagas.fold(0, (total, vaga) => total + vaga.candidaturas);

  List<CursoOficina> cursosDaVaga(String vagaId) =>
      paraAprovar.where((c) => c.vagaId == vagaId).toList();

  Future<void> carregar(String empresaId) async {
    carregando = true;
    erroGeral = null;
    notifyListeners();
    try {
      vagas = (await _vagas.vagasDaEmpresa(empresaId))
        ..sort((a, b) => a.titulo.compareTo(b.titulo));
      paraAprovar = await _vagas.cursosParaAprovar(empresaId);
    } on Exception {
      erroGeral = _erroCarregar;
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<bool> aprovar({
    required Usuario usuario,
    required PerfilEmpresa empresa,
    required CursoOficina curso,
  }) async {
    final aprovou = await executar(
      () => _decidir.aprovar(usuario: usuario, empresa: empresa, curso: curso),
    );
    if (aprovou) await carregar(empresa.id);
    return aprovou;
  }

  Future<bool> recusar({
    required Usuario usuario,
    required PerfilEmpresa empresa,
    required CursoOficina curso,
  }) async {
    final recusou = await executar(
      () => _decidir.recusar(usuario: usuario, empresa: empresa, curso: curso),
    );
    if (recusou) await carregar(empresa.id);
    return recusou;
  }
}

/// O1 do protótipo: os cursos da oficina, com os rascunhos para publicar.
class PainelOficinaViewModel extends PublicacaoViewModel {
  PainelOficinaViewModel(this._vagas, this._publicar);

  final RepositorioVagas _vagas;
  final PublicarCurso _publicar;

  List<CursoOficina> cursos = const [];

  Future<void> carregar(String oficinaId) async {
    carregando = true;
    erroGeral = null;
    notifyListeners();
    try {
      cursos = (await _vagas.cursosDaOficina(oficinaId))
        ..sort((a, b) => a.nome.compareTo(b.nome));
    } on Exception {
      erroGeral = _erroCarregar;
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<bool> publicarRascunho({
    required Usuario usuario,
    required PerfilOficina oficina,
    required CursoOficina curso,
  }) async {
    final publicou = await executar(
      () => _publicar.publicarRascunho(
        usuario: usuario,
        oficina: oficina,
        curso: curso,
      ),
    );
    if (publicou) await carregar(oficina.id);
    return publicou;
  }
}
