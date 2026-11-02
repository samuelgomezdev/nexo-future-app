import 'package:flutter/material.dart';

import '../../domain/models/curso.dart';
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
    return _Etiqueta(texto: texto, icone: icone, fundo: fundo, frente: frente);
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({
    required this.texto,
    required this.icone,
    required this.fundo,
    required this.frente,
  });

  final String texto;
  final IconData icone;
  final Color fundo;
  final Color frente;

  @override
  Widget build(BuildContext context) {
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

/// Situação do curso com ícone e texto, como no O1 do protótipo.
class SituacaoCursoChip extends StatelessWidget {
  const SituacaoCursoChip(this.situacao, {super.key});

  final SituacaoCurso situacao;

  @override
  Widget build(BuildContext context) {
    final (texto, icone, fundo, frente) = switch (situacao) {
      SituacaoCurso.aprovado => (
        'Aprovado',
        Icons.check,
        CoresNexo.sucessoFundo,
        CoresNexo.sucesso,
      ),
      SituacaoCurso.emAnalise => (
        'Em análise',
        Icons.schedule,
        CoresNexo.primaria100,
        CoresNexo.primaria500,
      ),
      SituacaoCurso.rascunho => (
        'Rascunho',
        Icons.edit_outlined,
        CoresNexo.alertaFundo,
        CoresNexo.alerta,
      ),
      SituacaoCurso.recusado => (
        'Recusado',
        Icons.close,
        CoresNexo.erroFundo,
        CoresNexo.erro,
      ),
    };
    return _Etiqueta(texto: texto, icone: icone, fundo: fundo, frente: frente);
  }
}
