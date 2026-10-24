import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/vaga.dart';
import '../viewmodels/candidaturas_viewmodel.dart';
import 'detalhe_vaga_screen.dart';

/// F4: candidaturas ativas do aluno, com a opção de desistir.
class MinhasCandidaturasScreen extends StatelessWidget {
  const MinhasCandidaturasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CandidaturasViewModel>();
    final vagas = viewModel.vagasCandidatadas;

    return Scaffold(
      appBar: AppBar(title: const Text('Minhas candidaturas')),
      body: vagas.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Você ainda não se candidatou a nenhuma vaga.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(
                    '${viewModel.totalAtivas} de ${viewModel.limite} '
                    'candidaturas ativas',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                for (final vaga in vagas)
                  Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ListTile(
                      title: Text(vaga.titulo),
                      subtitle: Text('${vaga.empresa} · ${vaga.cidade}'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DetalheVagaScreen(vaga: vaga),
                        ),
                      ),
                      trailing: TextButton(
                        onPressed: () =>
                            _confirmarDesistencia(context, viewModel, vaga),
                        child: const Text('Desistir'),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Future<void> _confirmarDesistencia(
    BuildContext context,
    CandidaturasViewModel viewModel,
    Vaga vaga,
  ) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: const Text('Desistir da vaga?'),
        content: Text(
          'Você deixa de concorrer à vaga ${vaga.titulo} e libera '
          'um espaço no seu limite de ${viewModel.limite} candidaturas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogo).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogo).pop(true),
            child: const Text('Desistir'),
          ),
        ],
      ),
    );
    if (confirmou != true) return;
    viewModel.desistir(vaga);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Você desistiu da vaga ${vaga.titulo}.')),
    );
  }
}
