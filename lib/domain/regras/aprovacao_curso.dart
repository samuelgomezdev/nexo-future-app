import '../autenticacao.dart';
import '../erros.dart';
import '../models/curso.dart';
import '../models/empresa.dart';
import 'vinculo_cursos.dart';

/// RF0007 e RF0015: o recrutador aprova ou recusa os cursos propostos para
/// as próprias vagas. Ao aprovar, o curso é vinculado (RN0006: no máximo 5)
/// e a vaga aberta passa a aceitar candidaturas (RF0008).
class DecidirCurso {
  DecidirCurso(this._vagas);

  final RepositorioVagas _vagas;

  Future<Vaga> _vagaDaEmpresa(
    Usuario usuario,
    PerfilEmpresa empresa,
    CursoOficina curso,
  ) async {
    if (!usuario.emailVerificado) throw const EmailNaoVerificado();
    if (usuario.id != empresa.id || curso.empresaId != empresa.id) {
      throw const AcaoNaoPermitida();
    }
    final vaga = await _vagas.buscarVaga(curso.vagaId);
    if (vaga == null || vaga.empresaId != empresa.id) {
      throw const AcaoNaoPermitida();
    }
    if (curso.situacao != SituacaoCurso.emAnalise) {
      throw const CursoJaDecidido();
    }
    return vaga;
  }

  Future<Vaga> aprovar({
    required Usuario usuario,
    required PerfilEmpresa empresa,
    required CursoOficina curso,
  }) async {
    final vaga = await _vagaDaEmpresa(usuario, empresa, curso);
    final atualizada = vaga.copiar(
      cursos: vincularCurso(vaga.cursos, curso.vinculo),
      situacao: vaga.situacao == SituacaoVaga.aberta
          ? SituacaoVaga.aguardandoIngresso
          : vaga.situacao,
    );
    await _vagas.decidirCurso(
      curso.copiar(situacao: SituacaoCurso.aprovado),
      vaga: atualizada,
    );
    return atualizada;
  }

  Future<CursoOficina> recusar({
    required Usuario usuario,
    required PerfilEmpresa empresa,
    required CursoOficina curso,
  }) async {
    await _vagaDaEmpresa(usuario, empresa, curso);
    final recusado = curso.copiar(situacao: SituacaoCurso.recusado);
    await _vagas.decidirCurso(recusado);
    return recusado;
  }
}
