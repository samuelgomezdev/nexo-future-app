import 'package:flutter/material.dart';

import '../../domain/regras/cadastro_jovem.dart';
import '../tema.dart';
import 'politica_privacidade_screen.dart';

/// Barras de progresso e o nome da etapa, como no protótipo (C3 e C4).
class BarraEtapas extends StatelessWidget {
  const BarraEtapas({
    super.key,
    required this.etapa,
    required this.total,
    required this.rotulo,
  });

  final int etapa;
  final int total;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 1; i <= total; i++) ...[
              if (i > 1) const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: i <= etapa
                        ? CoresNexo.primaria500
                        : CoresNexo.neutro200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Etapa $etapa de $total · $rotulo',
          style: textos.bodyMedium?.copyWith(color: CoresNexo.primaria500),
        ),
      ],
    );
  }
}

/// Aviso que conta quantos campos ainda precisam de correção.
class ResumoErros extends StatelessWidget {
  const ResumoErros({super.key, required this.quantidade});

  final int quantidade;

  @override
  Widget build(BuildContext context) {
    final texto = quantidade == 1
        ? 'Corrija 1 campo para continuar.'
        : 'Corrija $quantidade campos para continuar.';
    return AvisoCadastro(
      texto: texto,
      icone: Icons.error_outline,
      fundo: CoresNexo.erroFundo,
      cor: CoresNexo.erro,
    );
  }
}

class AvisoCadastro extends StatelessWidget {
  const AvisoCadastro({
    super.key,
    required this.texto,
    required this.icone,
    required this.fundo,
    required this.cor,
  });

  final String texto;
  final IconData icone;
  final Color fundo;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: cor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(texto, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

/// Campo de senha com o botão de mostrar e esconder.
class CampoSenha extends StatefulWidget {
  const CampoSenha({
    super.key,
    required this.controller,
    this.rotulo = 'Senha',
    this.erro,
    this.aoMudar,
  });

  final TextEditingController controller;
  final String rotulo;
  final String? erro;
  final ValueChanged<String>? aoMudar;

  @override
  State<CampoSenha> createState() => _CampoSenhaState();
}

class _CampoSenhaState extends State<CampoSenha> {
  bool _visivel = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: !_visivel,
      autofillHints: const [AutofillHints.newPassword],
      onChanged: widget.aoMudar,
      decoration: InputDecoration(
        labelText: widget.rotulo,
        helperText: 'Pelo menos $tamanhoMinimoSenha caracteres.',
        errorText: widget.erro,
        suffixIcon: IconButton(
          tooltip: _visivel ? 'Esconder senha' : 'Mostrar senha',
          icon: Icon(
            _visivel
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          onPressed: () => setState(() => _visivel = !_visivel),
        ),
      ),
    );
  }
}

/// Lista de opções fixas, como as cidades da AMFRI ou os setores.
class CampoEscolha extends StatelessWidget {
  const CampoEscolha({
    super.key,
    required this.rotulo,
    required this.opcoes,
    required this.valor,
    required this.aoMudar,
    this.erro,
  });

  final String rotulo;
  final List<String> opcoes;
  final String? valor;
  final String? erro;
  final ValueChanged<String?> aoMudar;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: valor,
      decoration: InputDecoration(labelText: rotulo, errorText: erro),
      items: [
        for (final opcao in opcoes)
          DropdownMenuItem(value: opcao, child: Text(opcao)),
      ],
      onChanged: aoMudar,
    );
  }
}

/// Caixa de confirmação com o erro logo abaixo, quando houver.
class CaixaConfirmacao extends StatelessWidget {
  const CaixaConfirmacao({
    super.key,
    required this.texto,
    required this.marcado,
    required this.aoMudar,
    this.erro,
  });

  final String texto;
  final bool marcado;
  final String? erro;
  final ValueChanged<bool> aoMudar;

  @override
  Widget build(BuildContext context) {
    final erro = this.erro;
    return CheckboxListTile(
      value: marcado,
      onChanged: (valor) => aoMudar(valor ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      title: Text(texto),
      subtitle: erro == null
          ? null
          : Text(erro, style: const TextStyle(color: CoresNexo.erro)),
    );
  }
}

/// Aceite da Política de Privacidade, com o link para lê-la.
class AceitePolitica extends StatelessWidget {
  const AceitePolitica({
    super.key,
    required this.marcado,
    required this.aoMudar,
    this.erro,
  });

  final bool marcado;
  final String? erro;
  final ValueChanged<bool> aoMudar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CaixaConfirmacao(
          texto: 'Li e aceito a Política de Privacidade',
          marcado: marcado,
          erro: erro,
          aoMudar: aoMudar,
        ),
        TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const PoliticaPrivacidadeScreen(),
            ),
          ),
          child: const Text('Ler a Política de Privacidade'),
        ),
      ],
    );
  }
}

/// Botão principal que mostra o carregamento enquanto a conta é criada.
class BotaoCadastro extends StatelessWidget {
  const BotaoCadastro({
    super.key,
    required this.texto,
    required this.carregando,
    required this.aoTocar,
  });

  final String texto;
  final bool carregando;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: carregando ? null : aoTocar,
      child: carregando
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(texto),
    );
  }
}
