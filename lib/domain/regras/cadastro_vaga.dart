import '../autenticacao.dart';
import '../erros.dart';
import '../models/cadastro.dart';
import '../models/curso.dart';
import '../models/empresa.dart';
import 'cadastro_empresa.dart';
import 'cadastro_jovem.dart';
import 'vinculo_cursos.dart';

/// As áreas das vagas são os mesmos setores das empresas.
const areasVagas = setoresEmpresa;

const limitePosicoesVaga = 100;
const tamanhoMaximoCargo = 80;

/// O que o recrutador preenche na tela E2.
class DadosVaga {
  const DadosVaga({
    required this.titulo,
    required this.area,
    required this.posicoes,
    required this.cidade,
    required this.qualificacao,
    this.cursos = const [],
  });

  /// Cargo, como "Pintor(a) naval".
  final String titulo;
  final String area;

  /// Nulo quando o campo ficou vazio.
  final int? posicoes;
  final String cidade;
  final String qualificacao;

  /// Cursos preferenciais que o recrutador já escolheu (RF0015).
  final List<Curso> cursos;
}

/// Devolve os erros por campo; vazio quando a vaga pode ser publicada.
Map<CampoCadastro, String> validarVaga(DadosVaga dados) {
  final erros = <CampoCadastro, String>{};

  final titulo = dados.titulo.trim();
  if (titulo.isEmpty) {
    erros[CampoCadastro.titulo] = 'Informe o cargo da vaga.';
  } else if (titulo.length > tamanhoMaximoCargo) {
    erros[CampoCadastro.titulo] =
        'Use no máximo $tamanhoMaximoCargo caracteres no cargo.';
  }

  if (!areasVagas.contains(dados.area)) {
    erros[CampoCadastro.area] = 'Escolha a área da vaga.';
  }

  final posicoes = dados.posicoes;
  if (posicoes == null) {
    erros[CampoCadastro.posicoes] = 'Informe as posições.';
  } else if (posicoes < 1 || posicoes > limitePosicoesVaga) {
    erros[CampoCadastro.posicoes] =
        'As posições vão de 1 a $limitePosicoesVaga.';
  }

  if (!cidadesAmfri.contains(dados.cidade)) {
    erros[CampoCadastro.cidade] = 'Escolha a cidade da vaga.';
  }

  if (dados.qualificacao.trim().isEmpty) {
    erros[CampoCadastro.qualificacao] = 'Informe a qualificação exigida.';
  }

  // RN0006: os cursos passam pela mesma regra do vínculo.
  try {
    dados.cursos.fold(<Curso>[], vincularCurso);
  } on LimiteCursosAtingido {
    erros[CampoCadastro.cursos] =
        'Escolha no máximo $limiteCursosPorVaga cursos preferenciais.';
  } on CursoJaVinculado catch (e) {
    erros[CampoCadastro.cursos] = e.toString();
  }
  return erros;
}

/// RF0004: a empresa publica a vaga. Sem cursos, ela nasce aberta; com os
/// cursos preferenciais já escolhidos (RF0015), já aceita candidaturas.
/// RN0001: só depois de confirmar o e-mail.
class PublicarVaga {
  PublicarVaga(this._vagas);

  final RepositorioVagas _vagas;

  Future<Vaga> call({
    required Usuario usuario,
    required PerfilEmpresa empresa,
    required DadosVaga dados,
  }) async {
    if (!usuario.emailVerificado) throw const EmailNaoVerificado();
    if (usuario.id != empresa.id) throw const AcaoNaoPermitida();

    final erros = validarVaga(dados);
    if (erros.isNotEmpty) throw CadastroInvalido(erros);

    final vaga = Vaga(
      id: _vagas.novoId(),
      titulo: dados.titulo.trim(),
      empresa: empresa.nome,
      area: dados.area,
      cidade: dados.cidade,
      qualificacao: dados.qualificacao.trim(),
      situacao: dados.cursos.isEmpty
          ? SituacaoVaga.aberta
          : SituacaoVaga.aguardandoIngresso,
      cursos: List.unmodifiable(dados.cursos),
      empresaId: empresa.id,
      posicoes: dados.posicoes!,
    );
    await _vagas.salvarVaga(vaga);
    return vaga;
  }
}
