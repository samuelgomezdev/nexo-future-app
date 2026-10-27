import '../autenticacao.dart';
import '../models/jovem.dart';
import 'validacoes.dart';

/// Os 11 municípios da AMFRI, região atendida pelo Nexo Future.
const cidadesAmfri = [
  'Balneário Camboriú',
  'Balneário Piçarras',
  'Bombinhas',
  'Camboriú',
  'Ilhota',
  'Itajaí',
  'Itapema',
  'Luiz Alves',
  'Navegantes',
  'Penha',
  'Porto Belo',
];

const idadeMinima = 12;
const maioridade = 18;
const tamanhoMinimoSenha = 8;

int idadeEm(DateTime nascimento, DateTime hoje) {
  var idade = hoje.year - nascimento.year;
  final fezAniversario =
      hoje.month > nascimento.month ||
      (hoje.month == nascimento.month && hoje.day >= nascimento.day);
  if (!fezAniversario) idade--;
  return idade;
}

/// Devolve os erros por campo; vazio quando o cadastro pode seguir.
Map<CampoCadastro, String> validarCadastroJovem(
  DadosCadastroJovem dados, {
  required DateTime hoje,
}) {
  final erros = <CampoCadastro, String>{};

  final nome = dados.nome.trim();
  if (nome.isEmpty) {
    erros[CampoCadastro.nome] = 'Informe seu nome completo.';
  } else if (nome.split(RegExp(r'\s+')).length < 2) {
    erros[CampoCadastro.nome] = 'Informe nome e sobrenome.';
  }

  if (!emailValido(dados.email)) {
    erros[CampoCadastro.email] = 'Informe um e-mail válido.';
  }

  if (dados.senha.length < tamanhoMinimoSenha) {
    erros[CampoCadastro.senha] =
        'A senha precisa ter pelo menos $tamanhoMinimoSenha caracteres.';
  }

  if (!cidadesAmfri.contains(dados.cidade)) {
    erros[CampoCadastro.cidade] = 'Escolha sua cidade.';
  }

  final nascimento = dados.dataNascimento;
  if (nascimento == null) {
    erros[CampoCadastro.nascimento] = 'Informe sua data de nascimento.';
  } else if (nascimento.isAfter(hoje)) {
    erros[CampoCadastro.nascimento] = 'Data de nascimento inválida.';
  } else {
    final idade = idadeEm(nascimento, hoje);
    if (idade < idadeMinima) {
      erros[CampoCadastro.nascimento] =
          'O Nexo Future é para quem tem $idadeMinima anos ou mais.';
    } else if (idade < maioridade && !dados.autorizacaoResponsavel) {
      erros[CampoCadastro.responsavel] =
          'Confirme que seu responsável autorizou o cadastro.';
    }
  }

  if (!dados.aceitePolitica) {
    erros[CampoCadastro.politica] =
        'Aceite a Política de Privacidade para continuar.';
  }
  return erros;
}

/// Lançada quando o cadastro tem campos a corrigir.
class CadastroInvalido implements Exception {
  const CadastroInvalido(this.erros);

  final Map<CampoCadastro, String> erros;

  @override
  String toString() => erros.values.join('\n');
}

/// RF0003 e RF0016: cria a conta, envia a confirmação e salva o perfil.
class CadastrarJovem {
  CadastrarJovem(this._auth, this._perfis, {DateTime Function()? relogio})
    : _relogio = relogio ?? DateTime.now;

  final ServicoAutenticacao _auth;
  final RepositorioPerfis _perfis;
  final DateTime Function() _relogio;

  Future<PerfilJovem> call(DadosCadastroJovem dados) async {
    final agora = _relogio();
    final erros = validarCadastroJovem(dados, hoje: agora);
    if (erros.isNotEmpty) throw CadastroInvalido(erros);

    final email = dados.email.trim().toLowerCase();
    final usuario = await _auth.criarConta(email, dados.senha);
    await _auth.enviarConfirmacaoEmail();

    final perfil = PerfilJovem(
      id: usuario.id,
      nome: dados.nome.trim(),
      email: email,
      cidade: dados.cidade,
      dataNascimento: dados.dataNascimento!,
      autorizacaoResponsavel: dados.autorizacaoResponsavel,
      aceitePoliticaEm: agora,
    );
    await _perfis.salvarJovem(perfil);
    return perfil;
  }
}
