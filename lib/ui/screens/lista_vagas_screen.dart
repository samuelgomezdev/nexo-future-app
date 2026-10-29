import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app.dart';
import '../viewmodels/sessao_viewmodel.dart';
import '../viewmodels/vagas_viewmodel.dart';
import 'detalhe_vaga_screen.dart';
import 'login_screen.dart';
import 'minhas_candidaturas_screen.dart';
import 'situacao_chip.dart';

/// F1: lista e pesquisa de vagas.
class ListaVagasScreen extends StatelessWidget {
  const ListaVagasScreen({super.key});

  String _saudacao(SessaoViewModel sessao) {
    const convite = 'Encontre uma vaga e o curso que leva até ela.';
    if (!sessao.exigeLogin) return 'Olá, $alunoDemoNome! $convite';
    final nome = sessao.perfil?.nome.split(' ').first;
    return nome == null ? convite : 'Olá, $nome! $convite';
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<VagasViewModel>();
    final sessao = context.watch<SessaoViewModel>();
    final vagas = viewModel.vagas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vagas'),
        actions: [
          if (sessao.podeAgir)
            IconButton(
              tooltip: 'Minhas candidaturas',
              icon: const Icon(Icons.assignment_turned_in_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MinhasCandidaturasScreen(),
                ),
              ),
            ),
          if (sessao.logado)
            IconButton(
              tooltip: 'Sair',
              icon: const Icon(Icons.logout),
              onPressed: sessao.sair,
            )
          else if (sessao.exigeLogin)
            TextButton(
              key: const Key('botao-entrar'),
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const LoginScreen())),
              child: const Text('Entrar'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _saudacao(sessao),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Pesquisar vaga (ex.: solda)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: viewModel.pesquisar,
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FiltroArea(
                  rotulo: 'Todas',
                  selecionado: viewModel.areaSelecionada == null,
                  aoTocar: () => viewModel.filtrarArea(null),
                ),
                for (final area in viewModel.areas)
                  _FiltroArea(
                    rotulo: area,
                    selecionado: viewModel.areaSelecionada == area,
                    aoTocar: () => viewModel.filtrarArea(area),
                  ),
              ],
            ),
          ),
          Expanded(
            child: vagas.isEmpty
                ? const Center(child: Text('Nenhuma vaga encontrada.'))
                : ListView.builder(
                    itemCount: vagas.length + (viewModel.temMais ? 1 : 0),
                    itemBuilder: (context, indice) {
                      if (indice == vagas.length) {
                        // Chegou ao fim da página: carrega as próximas 15.
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => viewModel.carregarMais(),
                        );
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final vaga = vagas[indice];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          title: Text(vaga.titulo),
                          subtitle: Text('${vaga.empresa} · ${vaga.cidade}'),
                          trailing: SituacaoChip(vaga.situacao),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DetalheVagaScreen(vaga: vaga),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FiltroArea extends StatelessWidget {
  const _FiltroArea({
    required this.rotulo,
    required this.selecionado,
    required this.aoTocar,
  });

  final String rotulo;
  final bool selecionado;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(rotulo),
        selected: selecionado,
        onSelected: (_) => aoTocar(),
      ),
    );
  }
}
