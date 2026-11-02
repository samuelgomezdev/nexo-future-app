import '../autenticacao.dart';
import '../erros.dart';
import '../models/cadastro.dart';
import '../models/curso.dart';
import '../models/oficina.dart';
import 'alvara_oficina.dart';
import 'vinculo_cursos.dart';

const limiteCargaHoraria = 1000;
const limiteVagasTurma = 100;
const tamanhoMaximoNomeCurso = 80;
const tamanhoMaximoDescricao = 500;

/// O que o gestor da oficina preenche na tela O2.
class DadosCurso {
  const DadosCurso({
    required this.nome,
    required this.vaga,
    required this.cargaHoraria,
    required this.vagasTurma,
    required this.descricao,
  });

  final String nome;

  /// Vaga ligada ao curso (RF0015); a área do curso é a da vaga.
  final Vaga? vaga;

  /// Nulos quando o campo ficou vazio.
  final int? cargaHoraria;
  final int? vagasTurma;
  final String descricao;
}

/// A vaga recebe cursos quando tem empresa, não está lotada e ainda não
/// chegou a 5 cursos (RN0006). As vagas fictícias do seed não têm empresa.
bool aceitaNovosCursos(Vaga vaga) => _motivoVagaSemCursos(vaga) == null;

String? _motivoVagaSemCursos(Vaga vaga) {
  if (vaga.empresaId.isEmpty) return 'Escolha a vaga ligada ao curso.';
  if (vaga.situacao == SituacaoVaga.lotada) {
    return 'Esta vaga está lotada e não recebe cursos.';
  }
  if (vaga.cursos.length >= limiteCursosPorVaga) {
    return 'Esta vaga já tem $limiteCursosPorVaga cursos vinculados.';
  }
  return null;
}

/// Devolve os erros por campo; vazio quando o curso pode ser salvo.
Map<CampoCadastro, String> validarCurso(DadosCurso dados) {
  final erros = <CampoCadastro, String>{};

  final nome = dados.nome.trim();
  if (nome.isEmpty) {
    erros[CampoCadastro.nome] = 'Informe o nome do curso.';
  } else if (nome.length > tamanhoMaximoNomeCurso) {
    erros[CampoCadastro.nome] =
        'Use no máximo $tamanhoMaximoNomeCurso caracteres no nome.';
  }

  final vaga = dados.vaga;
  final motivo = vaga == null
      ? 'Escolha a vaga ligada ao curso.'
      : _motivoVagaSemCursos(vaga);
  if (motivo != null) erros[CampoCadastro.vaga] = motivo;

  final carga = dados.cargaHoraria;
  if (carga == null) {
    erros[CampoCadastro.cargaHoraria] = 'Informe a carga horária.';
  } else if (carga < 1 || carga > limiteCargaHoraria) {
    erros[CampoCadastro.cargaHoraria] =
        'A carga horária vai de 1 a $limiteCargaHoraria horas.';
  }

  final turma = dados.vagasTurma;
  if (turma == null) {
    erros[CampoCadastro.vagasTurma] = 'Informe as vagas na turma.';
  } else if (turma < 1 || turma > limiteVagasTurma) {
    erros[CampoCadastro.vagasTurma] =
        'As vagas na turma vão de 1 a $limiteVagasTurma.';
  }

  if (dados.descricao.trim().length > tamanhoMaximoDescricao) {
    erros[CampoCadastro.descricao] =
        'Use no máximo $tamanhoMaximoDescricao caracteres na descrição.';
  }
  return erros;
}

/// RF0005: a oficina monta o curso para uma vaga e o envia ao recrutador.
/// RN0003: só publica com o alvará em dia; sem ele, o curso fica em rascunho.
/// RN0001: só depois de confirmar o e-mail.
class PublicarCurso {
  PublicarCurso(this._vagas, {DateTime Function()? relogio})
    : _relogio = relogio ?? DateTime.now;

  final RepositorioVagas _vagas;
  final DateTime Function() _relogio;

  void _conferirConta(Usuario usuario, PerfilOficina oficina) {
    if (!usuario.emailVerificado) throw const EmailNaoVerificado();
    if (usuario.id != oficina.id) throw const AcaoNaoPermitida();
  }

  Future<CursoOficina> call({
    required Usuario usuario,
    required PerfilOficina oficina,
    required DadosCurso dados,
    bool rascunho = false,
  }) async {
    _conferirConta(usuario, oficina);
    final erros = validarCurso(dados);
    if (erros.isNotEmpty) throw CadastroInvalido(erros);
    if (!rascunho) conferirAlvara(oficina.oficina, hoje: _relogio());

    final vaga = dados.vaga!;
    final curso = CursoOficina(
      id: _vagas.novoId(),
      nome: dados.nome.trim(),
      area: vaga.area,
      cargaHoraria: dados.cargaHoraria!,
      vagasTurma: dados.vagasTurma!,
      descricao: dados.descricao.trim(),
      vagaId: vaga.id,
      vagaTitulo: vaga.titulo,
      empresaId: vaga.empresaId,
      empresa: vaga.empresa,
      oficinaId: oficina.id,
      oficina: oficina.nome,
      situacao: rascunho ? SituacaoCurso.rascunho : SituacaoCurso.emAnalise,
    );
    await _vagas.salvarCurso(curso);
    return curso;
  }

  /// Envia ao recrutador um curso salvo como rascunho.
  Future<CursoOficina> publicarRascunho({
    required Usuario usuario,
    required PerfilOficina oficina,
    required CursoOficina curso,
  }) async {
    _conferirConta(usuario, oficina);
    if (curso.oficinaId != oficina.id) throw const AcaoNaoPermitida();
    conferirAlvara(oficina.oficina, hoje: _relogio());

    final publicado = curso.copiar(situacao: SituacaoCurso.emAnalise);
    await _vagas.salvarCurso(publicado);
    return publicado;
  }
}
