import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/vaga.dart';
import '../viewmodels/candidaturas_viewmodel.dart';
import 'minhas_candidaturas_screen.dart';
import 'situacao_chip.dart';

/// F2: detalhe da vaga, com os cursos vinculados e o botão de candidatura (F3).
class DetalheVagaScreen extends StatelessWidget {
  const DetalheVagaScreen({super.key, required this.vaga});

  final Vaga vaga;

  @override
  Widget build(BuildContext context) {
    final candidaturas = context.watch<CandidaturasViewModel>();
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(vaga.titulo)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(vaga.titulo, style: textos.headlineSmall),
          const SizedBox(height: 4),
          Text('${vaga.empresa} · ${vaga.cidade}', style: textos.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              SituacaoChip(vaga.situacao),
              const SizedBox(width: 8),
              Text('Área: ${vaga.area}'),
            ],
          ),
          const SizedBox(height: 24),
          Text('Qualificação exigida', style: textos.titleMedium),
          const SizedBox(height: 4),
          Text(vaga.qualificacao),
          const SizedBox(height: 24),
          Text('Cursos vinculados', style: textos.titleMedium),
          const SizedBox(height: 4),
          if (vaga.cursos.isEmpty)
            const Text('O recrutador ainda não aprovou cursos para esta vaga.')
          else
            for (final curso in vaga.cursos)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.school_outlined),
                title: Text(curso.nome),
                subtitle: Text(curso.oficina),
              ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _BotaoCandidatura(vaga: vaga, candidaturas: candidaturas),
        ),
      ),
    );
  }
}

class _BotaoCandidatura extends StatelessWidget {
  const _BotaoCandidatura({required this.vaga, required this.candidaturas});

  final Vaga vaga;
  final CandidaturasViewModel candidaturas;

  @override
  Widget build(BuildContext context) {
    if (candidaturas.jaCandidatou(vaga)) {
      return const FilledButton(
        onPressed: null,
        child: Text('Candidatura enviada'),
      );
    }
    if (vaga.situacao != SituacaoVaga.aguardandoIngresso) {
      return const FilledButton(
        onPressed: null,
        child: Text('Vaga indisponível no momento'),
      );
    }
    return FilledButton(
      onPressed: () => _candidatar(context),
      child: const Text('Candidatar-se'),
    );
  }

  void _candidatar(BuildContext context) {
    final resultado = candidaturas.candidatar(vaga);
    final mensageiro = ScaffoldMessenger.of(context);
    switch (resultado) {
      case ResultadoCandidatura.enviada:
        mensageiro.showSnackBar(
          SnackBar(content: Text('Você se candidatou à vaga ${vaga.titulo}.')),
        );
      case ResultadoCandidatura.limiteAtingido:
        _avisarLimite(context);
      case ResultadoCandidatura.vagaIndisponivel:
        mensageiro.showSnackBar(
          const SnackBar(
            content: Text('Esta vaga não está recebendo candidaturas.'),
          ),
        );
      case ResultadoCandidatura.jaCandidatado:
        mensageiro.showSnackBar(
          const SnackBar(content: Text('Você já se candidatou a esta vaga.')),
        );
    }
  }

  /// UC0007 E1: no limite, explica a regra e leva para Minhas candidaturas.
  void _avisarLimite(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: const Text('Limite de candidaturas'),
        content: Text(
          'Você já tem ${candidaturas.limite} candidaturas ativas. '
          'Desista de uma para se candidatar a outra vaga.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogo).pop(),
            child: const Text('Fechar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogo).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MinhasCandidaturasScreen(),
                ),
              );
            },
            child: const Text('Minhas candidaturas'),
          ),
        ],
      ),
    );
  }
}
