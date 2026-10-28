import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/cadastro.dart';
import '../../domain/models/empresa.dart';
import '../../domain/regras/cadastro_empresa.dart';
import '../../domain/regras/cadastro_jovem.dart';
import '../mascara_cnpj.dart';
import '../tema.dart';
import '../viewmodels/cadastro_empresa_viewmodel.dart';
import 'componentes_cadastro.dart';
import 'login_screen.dart';

const _camposEtapa1 = {
  CampoCadastro.nome,
  CampoCadastro.cnpj,
  CampoCadastro.setor,
  CampoCadastro.email,
};

/// C3 do protótipo: cadastro da empresa em duas etapas (RF0001).
class CadastroEmpresaScreen extends StatefulWidget {
  const CadastroEmpresaScreen({super.key});

  @override
  State<CadastroEmpresaScreen> createState() => _CadastroEmpresaScreenState();
}

class _CadastroEmpresaScreenState extends State<CadastroEmpresaScreen> {
  final _razaoSocial = TextEditingController();
  final _cnpj = TextEditingController();
  final _email = TextEditingController();
  final _recrutador = TextEditingController();
  final _senha = TextEditingController();
  String? _setor;
  String? _cidade;
  bool _aceite = false;
  int _etapa = 1;

  @override
  void dispose() {
    _razaoSocial.dispose();
    _cnpj.dispose();
    _email.dispose();
    _recrutador.dispose();
    _senha.dispose();
    super.dispose();
  }

  DadosCadastroEmpresa get _dados => DadosCadastroEmpresa(
    nome: _razaoSocial.text,
    cnpj: _cnpj.text,
    setor: _setor ?? '',
    recrutador: _recrutador.text,
    email: _email.text,
    senha: _senha.text,
    cidade: _cidade ?? '',
    aceitePolitica: _aceite,
  );

  void _proximaEtapa() {
    final viewModel = context.read<CadastroEmpresaViewModel>();
    final podeSeguir = viewModel.conferirEtapa(
      validarCadastroEmpresa(_dados),
      _camposEtapa1,
    );
    if (podeSeguir) setState(() => _etapa = 2);
  }

  void _voltar() {
    if (_etapa == 2) {
      context.read<CadastroEmpresaViewModel>().conferirEtapa(
        const {},
        const {},
      );
      setState(() => _etapa = 1);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _criarConta() async {
    final viewModel = context.read<CadastroEmpresaViewModel>();
    final navegador = Navigator.of(context);
    final cadastrou = await viewModel.cadastrar(_dados);
    if (cadastrou) {
      navegador.pushReplacement(
        MaterialPageRoute(
          builder: (_) => ConfirmeEmailScreen(email: viewModel.perfil!.email),
        ),
      );
    } else if (viewModel.erros.keys.any(_camposEtapa1.contains)) {
      setState(() => _etapa = 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CadastroEmpresaViewModel>();
    final erros = viewModel.erros;
    final textos = Theme.of(context).textTheme;

    return PopScope(
      canPop: _etapa == 1,
      onPopInvokedWithResult: (saiu, _) {
        if (!saiu) _voltar();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Voltar',
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: _voltar,
          ),
          title: const Text('Cadastro da empresa'),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            BarraEtapas(
              etapa: _etapa,
              total: 2,
              rotulo: _etapa == 1 ? 'Dados da empresa' : 'Acesso',
            ),
            const SizedBox(height: 20),
            if (_etapa == 1) ...[
              TextField(
                controller: _razaoSocial,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Razão social *',
                  errorText: erros[CampoCadastro.nome],
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _cnpj,
                keyboardType: TextInputType.number,
                inputFormatters: [MascaraCnpj()],
                decoration: InputDecoration(
                  labelText: 'CNPJ *',
                  hintText: '00.000.000/0000-00',
                  errorText: erros[CampoCadastro.cnpj],
                ),
              ),
              const SizedBox(height: 14),
              CampoEscolha(
                key: const Key('campo-setor'),
                rotulo: 'Setor *',
                opcoes: setoresEmpresa,
                valor: _setor,
                erro: erros[CampoCadastro.setor],
                aoMudar: (setor) => setState(() => _setor = setor),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(
                  labelText: 'E-mail do recrutador *',
                  hintText: 'rh@empresa.com.br',
                  helperText: 'Usaremos para enviar a validação.',
                  errorText: erros[CampoCadastro.email],
                  errorMaxLines: 2,
                ),
              ),
            ] else ...[
              TextField(
                controller: _recrutador,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                decoration: InputDecoration(
                  labelText: 'Nome do recrutador *',
                  errorText: erros[CampoCadastro.recrutador],
                ),
              ),
              const SizedBox(height: 14),
              CampoEscolha(
                key: const Key('campo-cidade'),
                rotulo: 'Cidade *',
                opcoes: cidadesAmfri,
                valor: _cidade,
                erro: erros[CampoCadastro.cidade],
                aoMudar: (cidade) => setState(() => _cidade = cidade),
              ),
              const SizedBox(height: 14),
              CampoSenha(
                controller: _senha,
                rotulo: 'Senha *',
                erro: erros[CampoCadastro.senha],
              ),
              const SizedBox(height: 8),
              AceitePolitica(
                marcado: _aceite,
                erro: erros[CampoCadastro.politica],
                aoMudar: (valor) => setState(() => _aceite = valor),
              ),
            ],
            if (erros.isNotEmpty) ...[
              const SizedBox(height: 16),
              ResumoErros(quantidade: erros.length),
            ],
            if (viewModel.erroGeral case final erro?) ...[
              const SizedBox(height: 16),
              Text(
                erro,
                style: textos.bodyMedium?.copyWith(color: CoresNexo.erro),
              ),
            ],
            const SizedBox(height: 20),
            if (_etapa == 1)
              FilledButton(
                onPressed: _proximaEtapa,
                child: const Text('Próxima etapa'),
              )
            else
              BotaoCadastro(
                texto: 'Criar conta',
                carregando: viewModel.carregando,
                aoTocar: _criarConta,
              ),
          ],
        ),
      ),
    );
  }
}
