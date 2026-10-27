import 'package:flutter/material.dart';

import '../../domain/models/vaga.dart';
import '../tema.dart';

/// Situação da vaga com ícone e texto, para não depender só da cor.
class SituacaoChip extends StatelessWidget {
  const SituacaoChip(this.situacao, {super.key});

  final SituacaoVaga situacao;

  @override
  Widget build(BuildContext context) {
    final (texto, icone, fundo, frente) = switch (situacao) {
      SituacaoVaga.aguardandoIngresso => (
        'Aceitando candidaturas',
        Icons.check,
        CoresNexo.sucessoFundo,
        CoresNexo.sucesso,
      ),
      SituacaoVaga.aberta => (
        'Aguardando cursos',
        Icons.schedule,
        CoresNexo.alertaFundo,
        CoresNexo.alerta,
      ),
      SituacaoVaga.lotada => (
        'Lotada',
        Icons.close,
        CoresNexo.neutro200,
        CoresNexo.neutro700,
      ),
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 10, 4),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 14, color: frente),
          const SizedBox(width: 4),
          Text(
            texto,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: frente),
          ),
        ],
      ),
    );
  }
}
