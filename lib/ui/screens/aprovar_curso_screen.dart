import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/curso.dart';
import '../../domain/models/empresa.dart';
import '../../domain/regras/vinculo_cursos.dart';
import '../tema.dart';
import '../viewmodels/paineis_viewmodel.dart';
import '../viewmodels/sessao_viewmodel.dart';
import 'componentes_cadastro.dart';

/// E3 do protótipo: o recrutador aprova ou recusa o curso proposto para a
/// vaga (RF0007). Devolve a mensagem para o painel mostrar.
class AprovarCursoScreen extends StatelessWidget {
  const AprovarCursoScreen({
    super.key,
    required this.empresa,
    required this.curso,
  });

  final PerfilEmpresa empresa;
  final CursoOficina curso;

  Future<void> _decidir(BuildContext context, {required bool aprovar}) async {
    final painel = context.read<PainelEmpresaViewModel>();
    final usuario = context.read<SessaoViewModel>().usuario!;
    final navegador = Navigator.of(context);
    final vagaAberta = _vaga(painel)?.situacao == SituacaoVaga.aberta;
    final decidiu = aprovar
        ? await painel.aprovar(usuario: usuario, empresa: empresa, curso: curso)
        : await painel.recusar(
            usuario: usuario,
            empresa: empresa,
            curso: curso,
          );
    if (!decidiu) return;
    navegador.pop(
      !aprovar
          ? 'Curso recusado.'
          : vagaAberta
          ? 'Curso aprovado. A vaga já aceita candidaturas.'
          : 'Curso aprovado.',
    );
  }

  Vaga? _vaga(PainelEmpresaViewModel painel) {
    for (final vaga in painel.vagas) {
      if (vaga.id == curso.vagaId) return vaga;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final painel = context.watch<PainelEmpresaViewModel>();
    final textos = Theme.of(context).textTheme;
    final vaga = _vaga(painel);
    final posicoes = vaga == null
        ? ''
        : ' · ${vaga.posicoes} ${vaga.posicoes == 1 ? 'posição' : 'posições'}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Aprovar curso')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CoresNexo.neutro100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.work_outline,
                  size: 18,
                  color: CoresNexo.neutro700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Para a vaga: ${curso.vagaTitulo}$posicoes',
                    style: textos.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: CoresNexo.ambarFundo,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.school_outlined,
                  color: CoresNexo.alerta,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(curso.nome, style: textos.titleLarge),
                    Text(
                      curso.oficina,
                      style: textos.bodyMedium?.copyWith(
                        color: CoresNexo.neutro700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                _Linha(
                  icone: Icons.schedule,
                  rotulo: 'Carga horária',
                  valor: '${curso.cargaHoraria} horas',
                ),
                const Divider(height: 1),
                _Linha(
                  icone: Icons.groups_outlined,
                  rotulo: 'Turma',
                  valor: '${curso.vagasTurma} vagas',
                ),
                const Divider(height: 1),
                _Linha(
                  icone: Icons.link,
                  rotulo: 'Cursos da vaga',
                  valor:
                      '${vaga?.cursos.length ?? 0} de $limiteCursosPorVaga cursos vinculados',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('O que o curso ensina', style: textos.titleMedium),
          const SizedBox(height: 6),
          Text(
            curso.descricao.isEmpty
                ? 'A oficina não descreveu o curso.'
                : curso.descricao,
            style: textos.bodyMedium?.copyWith(color: CoresNexo.neutro700),
          ),
          const SizedBox(height: 24),
          AvisoCadastro(
            texto: vaga?.situacao == SituacaoVaga.aberta
                ? 'Ao aprovar, a vaga passa a aceitar candidaturas (RF0007).'
                : 'Ao aprovar, o curso aparece na vaga para os jovens.',
            icone: Icons.check_circle_outline,
            fundo: CoresNexo.sucessoFundo,
            cor: CoresNexo.sucesso,
          ),
          if (painel.erroGeral case final erro?) ...[
            const SizedBox(height: 16),
            Text(
              erro,
              style: textos.bodyMedium?.copyWith(color: CoresNexo.erro),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CoresNexo.erro,
                    side: const BorderSide(color: CoresNexo.erro, width: 1.5),
                  ),
                  onPressed: painel.carregando
                      ? null
                      : () => _decidir(context, aprovar: false),
                  child: const Text('Recusar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: painel.carregando
                      ? null
                      : () => _decidir(context, aprovar: true),
                  child: const Text('Aprovar curso'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha({
    required this.icone,
    required this.rotulo,
    required this.valor,
  });

  final IconData icone;
  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icone, size: 18, color: CoresNexo.neutro500),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              rotulo,
              style: textos.bodyMedium?.copyWith(color: CoresNexo.neutro700),
            ),
          ),
          Text(valor, style: textos.labelMedium),
        ],
      ),
    );
  }
}
