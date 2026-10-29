import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/erros.dart';
import '../../domain/models/empresa.dart';
import '../../domain/models/oficina.dart';
import '../../domain/regras/alvara_oficina.dart';
import '../mascara_data.dart';
import '../tema.dart';
import '../viewmodels/sessao_viewmodel.dart';
import 'componentes_cadastro.dart';
import 'lista_vagas_screen.dart';

/// E1 do protótipo, primeira versão: o painel ganha vagas na Sprint 3.
class InicioEmpresaScreen extends StatelessWidget {
  const InicioEmpresaScreen({super.key, required this.empresa});

  final PerfilEmpresa empresa;

  @override
  Widget build(BuildContext context) {
    return _Painel(
      titulo: empresa.nome,
      subtitulo: 'Painel do recrutador · ${empresa.setor} · ${empresa.cidade}',
      children: [
        _Secao(titulo: 'Suas vagas'),
        const _Vazio(
          icone: Icons.work_outline,
          texto: 'Você ainda não publicou vagas.',
        ),
      ],
    );
  }
}

/// O1 do protótipo, primeira versão: mostra se a oficina já publica cursos (RN0003).
class InicioOficinaScreen extends StatelessWidget {
  const InicioOficinaScreen({super.key, required this.oficina, this.hoje});

  final PerfilOficina oficina;

  /// Data usada para conferir a validade do alvará; nos testes, fixa.
  final DateTime? hoje;

  Widget _avisoAlvara() {
    try {
      conferirAlvara(oficina.oficina, hoje: hoje ?? DateTime.now());
      final validade = formatarDataBr(oficina.alvara!.validade);
      return AvisoCadastro(
        texto:
            'Alvará de ensino em dia, válido até $validade. Sua oficina pode publicar cursos.',
        icone: Icons.check_circle_outline,
        fundo: CoresNexo.sucessoFundo,
        cor: CoresNexo.sucesso,
      );
    } on AlvaraVencido {
      final validade = formatarDataBr(oficina.alvara!.validade);
      return AvisoCadastro(
        texto:
            'O alvará de ensino venceu em $validade. Envie o alvará renovado para publicar cursos.',
        icone: Icons.error_outline,
        fundo: CoresNexo.alertaFundo,
        cor: CoresNexo.alerta,
      );
    } on OficinaSemAlvara {
      return const AvisoCadastro(
        texto: 'Sem o alvará de ensino em dia, sua oficina ainda não publica cursos (RN0003).',
        icone: Icons.error_outline,
        fundo: CoresNexo.alertaFundo,
        cor: CoresNexo.alerta,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Painel(
      titulo: oficina.nome,
      subtitulo: 'Oficina escola · ${oficina.cidade}',
      children: [
        _avisoAlvara(),
        const SizedBox(height: 24),
        _Secao(titulo: 'Seus cursos'),
        const _Vazio(
          icone: Icons.school_outlined,
          texto: 'Você ainda não montou cursos.',
        ),
      ],
    );
  }
}

/// Cabeçalho com o logo e o nome, como nos painéis do protótipo.
class _Painel extends StatelessWidget {
  const _Painel({
    required this.titulo,
    required this.subtitulo,
    required this.children,
  });

  final String titulo;
  final String subtitulo;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: CoresNexo.neutro100,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Image.asset(
          'assets/imagens/logo_nexo.png',
          height: 36,
          semanticLabel: 'Nexo Future',
        ),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final navegador = Navigator.of(context);
              await context.read<SessaoViewModel>().sair();
              navegador.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const ListaVagasScreen()),
                (_) => false,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        children: [
          Text(titulo, style: textos.headlineSmall),
          const SizedBox(height: 4),
          Text(
            subtitulo,
            style: textos.bodyMedium?.copyWith(color: CoresNexo.neutro700),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _Secao extends StatelessWidget {
  const _Secao({required this.titulo});

  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(titulo, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

class _Vazio extends StatelessWidget {
  const _Vazio({required this.icone, required this.texto});

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CoresNexo.neutro200),
      ),
      child: Row(
        children: [
          Icon(icone, color: CoresNexo.neutro500),
          const SizedBox(width: 12),
          Expanded(
            child: Text(texto, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
