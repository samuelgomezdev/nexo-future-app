import '../autenticacao.dart';
import '../models/cadastro.dart';
import '../models/empresa.dart';
import 'cadastro_jovem.dart';
import 'validacoes.dart';

/// Os setores são as mesmas áreas usadas no filtro das vagas.
const setoresEmpresa = [
  'Alimentos',
  'Construção Civil',
  'Logística',
  'Metalurgia',
  'Naval',
  'Turismo e Hotelaria',
];

/// Devolve os erros por campo; vazio quando o cadastro pode seguir.
Map<CampoCadastro, String> validarCadastroEmpresa(DadosCadastroEmpresa dados) {
  final erros = <CampoCadastro, String>{};

  if (dados.nome.trim().isEmpty) {
    erros[CampoCadastro.nome] = 'Informe a razão social.';
  }

  if (!cnpjValido(dados.cnpj)) {
    erros[CampoCadastro.cnpj] = 'Informe um CNPJ válido.';
  }

  if (!setoresEmpresa.contains(dados.setor)) {
    erros[CampoCadastro.setor] = 'Escolha o setor da empresa.';
  }

  if (dados.recrutador.trim().isEmpty) {
    erros[CampoCadastro.recrutador] = 'Informe o nome de quem faz o cadastro.';
  } else if (!temSobrenome(dados.recrutador)) {
    erros[CampoCadastro.recrutador] = 'Informe nome e sobrenome.';
  }

  if (!emailValido(dados.email)) {
    erros[CampoCadastro.email] = 'Informe um e-mail válido.';
  }

  if (dados.senha.length < tamanhoMinimoSenha) {
    erros[CampoCadastro.senha] =
        'A senha precisa ter pelo menos $tamanhoMinimoSenha caracteres.';
  }

  if (!cidadesAmfri.contains(dados.cidade)) {
    erros[CampoCadastro.cidade] = 'Escolha a cidade da empresa.';
  }

  if (!dados.aceitePolitica) {
    erros[CampoCadastro.politica] =
        'Aceite a Política de Privacidade para continuar.';
  }
  return erros;
}

/// RF0001 e RF0016: cria a conta do recrutador, envia a confirmação e salva a empresa.
class CadastrarEmpresa {
  CadastrarEmpresa(this._auth, this._perfis, {DateTime Function()? relogio})
    : _relogio = relogio ?? DateTime.now;

  final ServicoAutenticacao _auth;
  final RepositorioPerfis _perfis;
  final DateTime Function() _relogio;

  Future<PerfilEmpresa> call(DadosCadastroEmpresa dados) async {
    final erros = validarCadastroEmpresa(dados);
    if (erros.isNotEmpty) throw CadastroInvalido(erros);

    final email = dados.email.trim().toLowerCase();
    final usuario = await _auth.criarConta(email, dados.senha);
    await _auth.enviarConfirmacaoEmail();

    final perfil = PerfilEmpresa(
      id: usuario.id,
      nome: dados.nome.trim(),
      cnpj: somenteDigitos(dados.cnpj),
      setor: dados.setor,
      recrutador: dados.recrutador.trim(),
      email: email,
      cidade: dados.cidade,
      aceitePoliticaEm: _relogio(),
    );
    await _perfis.salvarEmpresa(perfil);
    return perfil;
  }
}
