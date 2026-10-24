import 'package:flutter/material.dart';

import '../../domain/models/vaga.dart';

class SituacaoChip extends StatelessWidget {
  const SituacaoChip(this.situacao, {super.key});

  final SituacaoVaga situacao;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final (texto, fundo, frente) = switch (situacao) {
      SituacaoVaga.aguardandoIngresso => (
        'Aceitando candidaturas',
        cores.primaryContainer,
        cores.onPrimaryContainer,
      ),
      SituacaoVaga.aberta => (
        'Aguardando cursos',
        cores.surfaceContainerHighest,
        cores.onSurfaceVariant,
      ),
      SituacaoVaga.lotada => (
        'Lotada',
        cores.errorContainer,
        cores.onErrorContainer,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        texto,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: frente),
      ),
    );
  }
}
