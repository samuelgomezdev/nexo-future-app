import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/jovem.dart';
import '../../domain/regras/cadastro_jovem.dart';
import '../mascara_data.dart';
import '../tema.dart';
import '../viewmodels/cadastro_jovem_viewmodel.dart';
import 'componentes_cadastro.dart';
import 'login_screen.dart';
import 'politica_privacidade_screen.dart';

/// C2 do protótipo: cadastro do jovem, sem CPF (minimização da LGPD).
class CadastroJovemScreen extends StatefulWidget {
  const CadastroJovemScreen({super.key});

  @override
  State<CadastroJovemScreen> createState() => _CadastroJovemScreenState();
}

class _CadastroJovemScreenState extends State<CadastroJovemScreen> {
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _nascimento = TextEditingController();
  String? _cidade;
  bool _autorizacao = false;
  bool _aceite = false;
  bool _senhaVisivel = false;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senha.dispose();
    _nascimento.dispose();
    super.dispose();
  }

  Future<void> _criarConta() async {
    final viewModel = context.read<CadastroJovemViewModel>();
    final navegador = Navigator.of(context);
    final nascimento = lerDataBr(_nascimento.text);
    final cadastrou = await viewModel.cadastrar(
      DadosCadastroJovem(
        nome: _nome.text,
        email: _email.text,
        senha: _senha.text,
        cidade: _cidade ?? '',
        dataNascimento: nascimento,
        autorizacaoResponsavel:
            viewModel.precisaAutorizacao(nascimento) && _autorizacao,
        aceitePolitica: _aceite,
      ),
    );
    if (cadastrou) {
      navegador.pushReplacement(
        MaterialPageRoute(
          builder: (_) => ConfirmeEmailScreen(email: viewModel.perfil!.email),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CadastroJovemViewModel>();
    final erros = viewModel.erros;
    final textos = Theme.of(context).textTheme;
    final pedeAutorizacao = viewModel.precisaAutorizacao(
      lerDataBr(_nascimento.text),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Criar conta')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          Text(
            'Todos os campos são obrigatórios. Não pedimos CPF.',
            style: textos.bodySmall?.copyWith(color: CoresNexo.neutro500),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nome,
            textCapitalization: TextCapitalization.words,
            autofillHints: const [AutofillHints.name],
            decoration: InputDecoration(
              labelText: 'Nome completo',
              errorText: erros[CampoCadastro.nome],
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(
              labelText: 'E-mail',
              errorText: erros[CampoCadastro.email],
              errorMaxLines: 2,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _senha,
            obscureText: !_senhaVisivel,
            autofillHints: const [AutofillHints.newPassword],
            decoration: InputDecoration(
              labelText: 'Senha',
              helperText: 'Pelo menos $tamanhoMinimoSenha caracteres.',
              errorText: erros[CampoCadastro.senha],
              suffixIcon: IconButton(
                tooltip: _senhaVisivel ? 'Esconder senha' : 'Mostrar senha',
                icon: Icon(
                  _senhaVisivel
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () => setState(() => _senhaVisivel = !_senhaVisivel),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _nascimento,
            keyboardType: TextInputType.number,
            inputFormatters: [MascaraData()],
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Data de nascimento',
              hintText: 'dd/mm/aaaa',
              errorText: erros[CampoCadastro.nascimento],
              errorMaxLines: 2,
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            key: const Key('campo-cidade'),
            initialValue: _cidade,
            decoration: InputDecoration(
              labelText: 'Cidade',
              errorText: erros[CampoCadastro.cidade],
            ),
            items: [
              for (final cidade in cidadesAmfri)
                DropdownMenuItem(value: cidade, child: Text(cidade)),
            ],
            onChanged: (cidade) => setState(() => _cidade = cidade),
          ),
          if (pedeAutorizacao) ...[
            const SizedBox(height: 8),
            CaixaConfirmacao(
              texto: 'Meu responsável autorizou este cadastro',
              marcado: _autorizacao,
              erro: erros[CampoCadastro.responsavel],
              aoMudar: (valor) => setState(() => _autorizacao = valor),
            ),
          ],
          const SizedBox(height: 8),
          CaixaConfirmacao(
            texto: 'Li e aceito a Política de Privacidade',
            marcado: _aceite,
            erro: erros[CampoCadastro.politica],
            aoMudar: (valor) => setState(() => _aceite = valor),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PoliticaPrivacidadeScreen(),
                ),
              ),
              child: const Text('Ler a Política de Privacidade'),
            ),
          ),
          if (viewModel.erroGeral case final erro?) ...[
            const SizedBox(height: 8),
            Text(
              erro,
              style: textos.bodyMedium?.copyWith(color: CoresNexo.erro),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: viewModel.carregando ? null : _criarConta,
            child: viewModel.carregando
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Criar conta'),
          ),
        ],
      ),
    );
  }
}
