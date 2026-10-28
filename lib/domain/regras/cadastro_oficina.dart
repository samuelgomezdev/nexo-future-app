import '../autenticacao.dart';
import '../models/cadastro.dart';
import '../models/oficina.dart';
import 'cadastro_jovem.dart';
import 'validacoes.dart';

/// Devolve os erros por campo; vazio quando o cadastro pode seguir.
Map<CampoCadastro, String> validarCadastroOficina(
  DadosCadastroOficina dados, {
  required DateTime hoje,
}) {
  final erros = <CampoCadastro, String>{};

  if (dados.nome.trim().isEmpty) {
    erros[CampoCadastro.nome] = 'Informe o nome da oficina.';
  }

  if (!cnpjValido(dados.cnpj)) {
    erros[CampoCadastro.cnpj] = 'Informe um CNPJ válido.';
  }

  if (dados.gestor.trim().isEmpty) {
    erros[CampoCadastro.gestor] =
        'Informe o nome de quem responde pela oficina.';
  } else if (!temSobrenome(dados.gestor)) {
    erros[CampoCadastro.gestor] = 'Informe nome e sobrenome.';
  }

  if (!emailValido(dados.email)) {
    erros[CampoCadastro.email] = 'Informe um e-mail válido.';
  }

  if (dados.senha.length < tamanhoMinimoSenha) {
    erros[CampoCadastro.senha] =
        'A senha precisa ter pelo menos $tamanhoMinimoSenha caracteres.';
  }

  if (!cidadesAmfri.contains(dados.cidade)) {
    erros[CampoCadastro.cidade] = 'Escolha a cidade da oficina.';
  }

  // O alvará é opcional, mas, se vier, precisa estar completo e em dia.
  final numero = dados.numeroAlvara.trim();
  final validade = dados.validadeAlvara;
  if (numero.isNotEmpty && validade == null) {
    erros[CampoCadastro.alvara] = 'Informe a validade do alvará.';
  } else if (numero.isEmpty && validade != null) {
    erros[CampoCadastro.alvara] = 'Informe o número do alvará.';
  } else if (validade != null &&
      validade.isBefore(DateTime(hoje.year, hoje.month, hoje.day))) {
    erros[CampoCadastro.alvara] = 'Este alvará já venceu. Informe o alvará em dia ou deixe para enviar depois.';
  }

  if (!dados.aceitePolitica) {
    erros[CampoCadastro.politica] =
        'Aceite a Política de Privacidade para continuar.';
  }
  return erros;
}

/// RF0002 e RF0016: cria a conta do gestor, envia a confirmação e salva a oficina.
class CadastrarOficina {
  CadastrarOficina(this._auth, this._perfis, {DateTime Function()? relogio})
    : _relogio = relogio ?? DateTime.now;

  final ServicoAutenticacao _auth;
  final RepositorioPerfis _perfis;
  final DateTime Function() _relogio;

  Future<PerfilOficina> call(DadosCadastroOficina dados) async {
    final agora = _relogio();
    final erros = validarCadastroOficina(dados, hoje: agora);
    if (erros.isNotEmpty) throw CadastroInvalido(erros);

    final email = dados.email.trim().toLowerCase();
    final usuario = await _auth.criarConta(email, dados.senha);
    await _auth.enviarConfirmacaoEmail();

    final validade = dados.validadeAlvara;
    final perfil = PerfilOficina(
      id: usuario.id,
      nome: dados.nome.trim(),
      cnpj: somenteDigitos(dados.cnpj),
      gestor: dados.gestor.trim(),
      email: email,
      cidade: dados.cidade,
      alvara: validade == null
          ? null
          : Alvara(numero: dados.numeroAlvara.trim(), validade: validade),
      aceitePoliticaEm: agora,
    );
    await _perfis.salvarOficina(perfil);
    return perfil;
  }
}
