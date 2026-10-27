import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../tema.dart';
import '../viewmodels/login_viewmodel.dart';
import 'lista_vagas_screen.dart';

/// A2 e A3 do protótipo: entrar com e-mail e senha.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _senhaVisivel = false;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    final viewModel = context.read<LoginViewModel>();
    final navegador = Navigator.of(context);
    final entrou = await viewModel.entrar(_email.text, _senha.text);
    if (entrou) {
      navegador.pushReplacement(
        MaterialPageRoute(builder: (_) => const ListaVagasScreen()),
      );
    } else if (viewModel.bloqueado) {
      navegador.push(
        MaterialPageRoute(
          builder: (_) => BloqueioLoginScreen(tempo: viewModel.tempoBloqueio!),
        ),
      );
    } else if (viewModel.precisaConfirmarEmail) {
      navegador.push(
        MaterialPageRoute(
          builder: (_) => ConfirmeEmailScreen(email: _email.text.trim()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'assets/imagens/logo_nexo.png',
                height: 52,
                semanticLabel: 'Nexo Future',
              ),
            ),
            const SizedBox(height: 28),
            Text('Entrar', style: textos.headlineSmall),
            const SizedBox(height: 6),
            Text(
              'Use o e-mail que você cadastrou.',
              style: textos.bodyMedium?.copyWith(color: CoresNexo.neutro700),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'E-mail',
                errorText: viewModel.erroEmail,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _senha,
              obscureText: !_senhaVisivel,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (_) => _entrar(),
              decoration: InputDecoration(
                labelText: 'Senha',
                errorText: viewModel.erroSenha,
                errorMaxLines: 2,
                suffixIcon: IconButton(
                  tooltip: _senhaVisivel ? 'Esconder senha' : 'Mostrar senha',
                  icon: Icon(
                    _senhaVisivel
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _senhaVisivel = !_senhaVisivel),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const _AvisoTentativas(),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: viewModel.carregando ? null : _entrar,
              child: viewModel.carregando
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Entrar'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Explica a regra antes de o jovem esbarrar nela (RNF0007).
class _AvisoTentativas extends StatelessWidget {
  const _AvisoTentativas();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CoresNexo.primaria50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            size: 20,
            color: CoresNexo.primaria500,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Depois de 5 senhas erradas, o acesso fica bloqueado por 15 minutos.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// A4 do protótipo: bloqueio com contagem regressiva.
class BloqueioLoginScreen extends StatefulWidget {
  const BloqueioLoginScreen({super.key, required this.tempo});

  final Duration tempo;

  @override
  State<BloqueioLoginScreen> createState() => _BloqueioLoginScreenState();
}

class _BloqueioLoginScreenState extends State<BloqueioLoginScreen> {
  late final DateTime _fim = DateTime.now().add(widget.tempo);
  late Duration _restante = widget.tempo;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final restante = _fim.difference(DateTime.now());
      if (restante <= Duration.zero) {
        _timer?.cancel();
        if (mounted) Navigator.of(context).pop();
        return;
      }
      setState(() => _restante = restante);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          children: [
            const _Circulo(
              icone: Icons.lock_outline,
              fundo: CoresNexo.erroFundo,
              cor: CoresNexo.erro,
            ),
            const SizedBox(height: 16),
            Text(
              'Acesso bloqueado por segurança',
              style: textos.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Foram 5 tentativas com a senha errada. Para proteger sua conta, '
              'o login fica bloqueado por 15 minutos.',
              style: textos.bodyLarge?.copyWith(color: CoresNexo.neutro700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CoresNexo.neutro100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Tente de novo em',
                    style: textos.bodyMedium?.copyWith(
                      color: CoresNexo.neutro700,
                    ),
                  ),
                  Text(
                    formatarTempo(_restante),
                    style: textos.headlineMedium?.copyWith(
                      fontSize: 40,
                      color: CoresNexo.primaria500,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Voltar ao login'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mostra o tempo como mm:ss, arredondando os segundos para cima.
String formatarTempo(Duration tempo) {
  final segundos = (tempo.inMilliseconds / 1000).ceil();
  final mm = (segundos ~/ 60).toString().padLeft(2, '0');
  final ss = (segundos % 60).toString().padLeft(2, '0');
  return '$mm:$ss';
}

/// A5 do protótipo: pede a confirmação do e-mail.
class ConfirmeEmailScreen extends StatelessWidget {
  const ConfirmeEmailScreen({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          children: [
            const _Circulo(
              icone: Icons.mail_outline,
              fundo: CoresNexo.primaria100,
              cor: CoresNexo.primaria500,
            ),
            const SizedBox(height: 16),
            Text(
              'Confirme seu e-mail',
              style: textos.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Enviamos um link para $email. Toque nele para ativar sua conta '
              'e depois entre de novo.',
              style: textos.bodyLarge?.copyWith(color: CoresNexo.neutro700),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Já confirmei'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Circulo extends StatelessWidget {
  const _Circulo({required this.icone, required this.fundo, required this.cor});

  final IconData icone;
  final Color fundo;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(color: fundo, shape: BoxShape.circle),
      child: Icon(icone, size: 44, color: cor),
    );
  }
}
