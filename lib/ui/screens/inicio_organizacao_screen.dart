import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/erros.dart';
import '../../domain/models/curso.dart';
import '../../domain/models/empresa.dart';
import '../../domain/models/oficina.dart';
import '../../domain/regras/alvara_oficina.dart';
import '../../domain/regras/aprovacao_curso.dart';
import '../../domain/regras/cadastro_curso.dart';
import '../../domain/regras/vinculo_cursos.dart';
import '../mascara_data.dart';
import '../tema.dart';
import '../viewmodels/paineis_viewmodel.dart';
import '../viewmodels/sessao_viewmodel.dart';
import 'componentes_cadastro.dart';
import 'lista_vagas_screen.dart';
import 'nova_vaga_screen.dart';
import 'novo_curso_screen.dart';
import 'situacao_chip.dart';

/// E1 do protótipo: as vagas da empresa e os cursos que aguardam aprovação.
class InicioEmpresaScreen extends StatelessWidget {
  const InicioEmpresaScreen({super.key, required this.empresa});

  final PerfilEmpresa empresa;

  @override
  Widget build(BuildContext context) {
    final vagas = context.read<RepositorioVagas>();
    return ChangeNotifierProvider(
      create: (_) =>
          PainelEmpresaViewModel(vagas, DecidirCurso(vagas))
            ..carregar(empresa.id),
      child: _PainelEmpresa(empresa: empresa),
    );
  }
}

class _PainelEmpresa extends StatelessWidget {
  const _PainelEmpresa({required this.empresa});

  final PerfilEmpresa empresa;

  Future<void> _novaVaga(BuildContext context) async {
    final painel = context.read<PainelEmpresaViewModel>();
    final mensageiro = ScaffoldMessenger.of(context);
    final publicou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => NovaVagaScreen(empresa: empresa)),
    );
    if (publicou != true) return;
    await painel.carregar(empresa.id);
    mensageiro.showSnackBar(const SnackBar(content: Text('Vaga publicada.')));
  }

  @override
  Widget build(BuildContext context) {
    final painel = context.watch<PainelEmpresaViewModel>();
    final paraAprovar = painel.paraAprovar.length;
    final aguardam = paraAprovar == 1
        ? '1 curso aguarda'
        : '$paraAprovar cursos aguardam';
    return _Painel(
      titulo: empresa.nome,
      subtitulo: 'Painel do recrutador · ${empresa.setor} · ${empresa.cidade}',
      botao: FloatingActionButton.extended(
        onPressed: () => _novaVaga(context),
        icon: const Icon(Icons.add),
        label: const Text('Nova vaga'),
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: _Numero(
                key: const Key('total-vagas-abertas'),
                icone: Icons.work_outline,
                valor: painel.vagasAbertas,
                rotulo: 'Vagas abertas',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Numero(
                key: const Key('total-cursos-para-aprovar'),
                icone: Icons.school_outlined,
                valor: paraAprovar,
                rotulo: 'Cursos p/ aprovar',
                destaque: paraAprovar > 0,
              ),
            ),
          ],
        ),
        if (paraAprovar > 0) ...[
          const SizedBox(height: 16),
          AvisoCadastro(
            texto:
                '$aguardam sua aprovação. Sem curso aprovado, a vaga não recebe candidaturas.',
            icone: Icons.error_outline,
            fundo: CoresNexo.alertaFundo,
            cor: CoresNexo.alerta,
          ),
        ],
        if (painel.erroGeral case final erro?) ...[
          const SizedBox(height: 16),
          AvisoCadastro(
            texto: erro,
            icone: Icons.wifi_off,
            fundo: CoresNexo.erroFundo,
            cor: CoresNexo.erro,
          ),
        ],
        const SizedBox(height: 24),
        _Secao(titulo: 'Suas vagas'),
        if (painel.vagas.isEmpty && !painel.carregando)
          const _Vazio(
            icone: Icons.work_outline,
            texto: 'Você ainda não publicou vagas.',
          ),
        for (final vaga in painel.vagas)
          _CartaoVaga(vaga: vaga, propostos: painel.cursosDaVaga(vaga.id)),
        // Espaço para o botão Nova vaga não cobrir a última vaga.
        const SizedBox(height: 72),
      ],
    );
  }
}

/// Número de destaque do painel, como nos cartões do protótipo.
class _Numero extends StatelessWidget {
  const _Numero({
    super.key,
    required this.icone,
    required this.valor,
    required this.rotulo,
    this.destaque = false,
  });

  final IconData icone;
  final int valor;
  final String rotulo;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: destaque ? CoresNexo.ambarFundo : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CoresNexo.neutro200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icone,
            size: 20,
            color: destaque ? CoresNexo.alerta : CoresNexo.primaria500,
          ),
          const SizedBox(height: 6),
          Text('$valor', style: textos.headlineSmall),
          Text(
            rotulo,
            style: textos.bodySmall?.copyWith(color: CoresNexo.neutro700),
          ),
        ],
      ),
    );
  }
}

/// Vaga da empresa, com os cursos que as oficinas propuseram para ela.
class _CartaoVaga extends StatelessWidget {
  const _CartaoVaga({required this.vaga, required this.propostos});

  final Vaga vaga;
  final List<CursoOficina> propostos;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final resumo = switch (propostos.length) {
      0 => '${vaga.cursos.length} de $limiteCursosPorVaga cursos',
      1 => '1 curso para aprovar',
      final n => '$n cursos para aprovar',
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(vaga.titulo, style: textos.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                SituacaoChip(vaga.situacao),
                const Spacer(),
                Text(
                  resumo,
                  style: textos.bodySmall?.copyWith(color: CoresNexo.neutro700),
                ),
              ],
            ),
            for (final curso in propostos)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.school_outlined,
                  color: CoresNexo.alerta,
                ),
                title: Text(curso.nome),
                subtitle: Text('${curso.oficina} · ${curso.cargaHoraria} h'),
                trailing: const Icon(Icons.chevron_right),
              ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

/// O1 do protótipo: os cursos da oficina e se ela já publica (RN0003).
class InicioOficinaScreen extends StatelessWidget {
  const InicioOficinaScreen({super.key, required this.oficina, this.hoje});

  final PerfilOficina oficina;

  /// Data usada para conferir a validade do alvará; nos testes, fixa.
  final DateTime? hoje;

  @override
  Widget build(BuildContext context) {
    final vagas = context.read<RepositorioVagas>();
    return ChangeNotifierProvider(
      create: (_) => PainelOficinaViewModel(
        vagas,
        PublicarCurso(vagas, relogio: hoje == null ? null : () => hoje!),
      )..carregar(oficina.id),
      child: _PainelOficina(oficina: oficina, hoje: hoje),
    );
  }
}

class _PainelOficina extends StatelessWidget {
  const _PainelOficina({required this.oficina, this.hoje});

  final PerfilOficina oficina;
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

  Future<void> _novoCurso(BuildContext context) async {
    final painel = context.read<PainelOficinaViewModel>();
    final mensageiro = ScaffoldMessenger.of(context);
    final curso = await Navigator.of(context).push<CursoOficina>(
      MaterialPageRoute(
        builder: (_) => NovoCursoScreen(oficina: oficina, hoje: hoje),
      ),
    );
    if (curso == null) return;
    await painel.carregar(oficina.id);
    mensageiro.showSnackBar(
      SnackBar(
        content: Text(
          curso.situacao == SituacaoCurso.rascunho
              ? 'Rascunho salvo.'
              : 'Curso enviado para aprovação.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final painel = context.watch<PainelOficinaViewModel>();
    final podePublicar = podePublicarCurso(
      oficina.oficina,
      hoje: hoje ?? DateTime.now(),
    );
    return _Painel(
      titulo: oficina.nome,
      subtitulo: 'Oficina escola · ${oficina.cidade}',
      children: [
        _avisoAlvara(),
        if (painel.erroGeral case final erro?) ...[
          const SizedBox(height: 16),
          AvisoCadastro(
            texto: erro,
            icone: Icons.error_outline,
            fundo: CoresNexo.erroFundo,
            cor: CoresNexo.erro,
          ),
        ],
        const SizedBox(height: 24),
        _Secao(titulo: 'Seus cursos'),
        if (painel.cursos.isEmpty && !painel.carregando)
          const _Vazio(
            icone: Icons.school_outlined,
            texto: 'Você ainda não montou cursos.',
          ),
        for (final curso in painel.cursos)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              leading: const Icon(
                Icons.school_outlined,
                color: CoresNexo.primaria500,
              ),
              title: Text(curso.nome),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${curso.vagaTitulo} · ${curso.empresa}'),
                  const SizedBox(height: 6),
                  SituacaoCursoChip(curso.situacao),
                ],
              ),
              trailing: curso.situacao == SituacaoCurso.rascunho && podePublicar
                  ? TextButton(
                      onPressed: painel.carregando
                          ? null
                          : () => painel.publicarRascunho(
                              usuario: context.read<SessaoViewModel>().usuario!,
                              oficina: oficina,
                              curso: curso,
                            ),
                      child: const Text('Publicar'),
                    )
                  : null,
            ),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _novoCurso(context),
          icon: const Icon(Icons.add),
          label: const Text('Novo curso'),
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
    this.botao,
  });

  final String titulo;
  final String subtitulo;
  final List<Widget> children;
  final Widget? botao;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: CoresNexo.neutro100,
      floatingActionButton: botao,
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
