import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/cadastro.dart';
import '../../domain/models/oficina.dart';
import '../../domain/regras/cadastro_jovem.dart';
import '../../domain/regras/cadastro_oficina.dart';
import '../mascara_cnpj.dart';
import '../mascara_data.dart';
import '../tema.dart';
import '../viewmodels/cadastro_jovem_viewmodel.dart';
import '../viewmodels/cadastro_oficina_viewmodel.dart';
import 'componentes_cadastro.dart';
import 'login_screen.dart';

const _camposEtapa1 = {
  CampoCadastro.nome,
  CampoCadastro.cnpj,
  CampoCadastro.gestor,
  CampoCadastro.cidade,
  CampoCadastro.email,
  CampoCadastro.senha,
  CampoCadastro.politica,
};

/// C4 do protótipo: cadastro da oficina, com o alvará na segunda etapa (RF0002).
class CadastroOficinaScreen extends StatefulWidget {
  const CadastroOficinaScreen({super.key});

  @override
  State<CadastroOficinaScreen> createState() => _CadastroOficinaScreenState();
}

class _CadastroOficinaScreenState extends State<CadastroOficinaScreen> {
  final _nome = TextEditingController();
  final _cnpj = TextEditingController();
  final _gestor = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _numeroAlvara = TextEditingController();
  final _validadeAlvara = TextEditingController();
  String? _cidade;
  bool _aceite = false;
  int _etapa = 1;

  @override
  void dispose() {
    _nome.dispose();
    _cnpj.dispose();
    _gestor.dispose();
    _email.dispose();
    _senha.dispose();
    _numeroAlvara.dispose();
    _validadeAlvara.dispose();
    super.dispose();
  }

  DadosCadastroOficina _dados({bool comAlvara = true}) => DadosCadastroOficina(
    nome: _nome.text,
    cnpj: _cnpj.text,
    gestor: _gestor.text,
    email: _email.text,
    senha: _senha.text,
    cidade: _cidade ?? '',
    numeroAlvara: comAlvara ? _numeroAlvara.text : '',
    validadeAlvara: comAlvara ? lerDataBr(_validadeAlvara.text) : null,
    aceitePolitica: _aceite,
  );

  void _proximaEtapa() {
    final viewModel = context.read<CadastroOficinaViewModel>();
    final podeSeguir = viewModel.conferirEtapa(
      validarCadastroOficina(_dados(comAlvara: false), hoje: DateTime.now()),
      _camposEtapa1,
    );
    if (podeSeguir) setState(() => _etapa = 2);
  }

  void _voltar() {
    if (_etapa == 2) {
      context.read<CadastroOficinaViewModel>().conferirEtapa(
        const {},
        const {},
      );
      setState(() => _etapa = 1);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  /// "Enviar depois" cadastra a oficina sem o alvará (RN0003).
  Future<void> _concluir({required bool comAlvara}) async {
    final viewModel = context.read<CadastroOficinaViewModel>();
    final navegador = Navigator.of(context);
    final cadastrou = await viewModel.cadastrar(_dados(comAlvara: comAlvara));
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
    final viewModel = context.watch<CadastroOficinaViewModel>();
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
          title: const Text('Cadastro da oficina'),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            BarraEtapas(
              etapa: _etapa,
              total: 2,
              rotulo: _etapa == 1 ? 'Dados da oficina' : 'Documentação',
            ),
            const SizedBox(height: 20),
            if (_etapa == 1) ...[
              TextField(
                controller: _nome,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Nome da oficina *',
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
              TextField(
                controller: _gestor,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                decoration: InputDecoration(
                  labelText: 'Nome do responsável *',
                  helperText: 'Gestor ou professor da oficina.',
                  errorText: erros[CampoCadastro.gestor],
                  errorMaxLines: 2,
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
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                enableSuggestions: false,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(
                  labelText: 'E-mail *',
                  helperText: 'Usaremos para enviar a validação.',
                  errorText: erros[CampoCadastro.email],
                  errorMaxLines: 2,
                ),
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
            ] else ...[
              Text('Informe o alvará de ensino', style: textos.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Com o alvará em dia, sua oficina pode publicar cursos.',
                style: textos.bodyMedium?.copyWith(color: CoresNexo.neutro700),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _numeroAlvara,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Número do alvará',
                  errorText: erros[CampoCadastro.alvara],
                  errorMaxLines: 3,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _validadeAlvara,
                keyboardType: TextInputType.number,
                inputFormatters: [MascaraData()],
                decoration: const InputDecoration(
                  labelText: 'Validade',
                  hintText: 'dd/mm/aaaa',
                ),
              ),
              const SizedBox(height: 20),
              const AvisoCadastro(
                texto: 'Sem o alvará em dia, a oficina pode entrar no app, mas não publica cursos (RN0003).',
                icone: Icons.info_outline,
                fundo: CoresNexo.ambarFundo,
                cor: CoresNexo.alerta,
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
            else ...[
              BotaoCadastro(
                texto: 'Concluir cadastro',
                carregando: viewModel.carregando,
                aoTocar: () => _concluir(comAlvara: true),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: viewModel.carregando
                    ? null
                    : () => _concluir(comAlvara: false),
                child: const Text('Enviar depois'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
