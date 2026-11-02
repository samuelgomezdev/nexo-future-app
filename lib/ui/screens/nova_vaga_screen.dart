import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../domain/models/cadastro.dart';
import '../../domain/models/curso.dart';
import '../../domain/models/empresa.dart';
import '../../domain/regras/cadastro_jovem.dart';
import '../../domain/regras/cadastro_vaga.dart';
import '../../domain/regras/vinculo_cursos.dart';
import '../tema.dart';
import '../viewmodels/nova_vaga_viewmodel.dart';
import '../viewmodels/sessao_viewmodel.dart';
import 'componentes_cadastro.dart';

/// E2 do protótipo: a empresa publica uma vaga (RF0004). Devolve true ao
/// publicar.
class NovaVagaScreen extends StatelessWidget {
  const NovaVagaScreen({super.key, required this.empresa});

  final PerfilEmpresa empresa;

  @override
  Widget build(BuildContext context) {
    final vagas = context.read<RepositorioVagas>();
    return ChangeNotifierProvider(
      create: (_) =>
          NovaVagaViewModel(PublicarVaga(vagas), vagas)..carregarCursos(),
      child: _FormularioVaga(empresa: empresa),
    );
  }
}

class _FormularioVaga extends StatefulWidget {
  const _FormularioVaga({required this.empresa});

  final PerfilEmpresa empresa;

  @override
  State<_FormularioVaga> createState() => _FormularioVagaState();
}

class _FormularioVagaState extends State<_FormularioVaga> {
  final _titulo = TextEditingController();
  final _posicoes = TextEditingController();
  final _qualificacao = TextEditingController();
  final _cursos = <Curso>[];

  // Menos texto, mais ação (RNF0005): começa com o setor e a cidade da empresa.
  late String? _area = areasVagas.contains(widget.empresa.setor)
      ? widget.empresa.setor
      : null;
  late String? _cidade = cidadesAmfri.contains(widget.empresa.cidade)
      ? widget.empresa.cidade
      : null;

  @override
  void dispose() {
    _titulo.dispose();
    _posicoes.dispose();
    _qualificacao.dispose();
    super.dispose();
  }

  void _limpar(CampoCadastro campo) =>
      context.read<NovaVagaViewModel>().limparErro(campo);

  Future<void> _publicar() async {
    final viewModel = context.read<NovaVagaViewModel>();
    final navegador = Navigator.of(context);
    final publicou = await viewModel.publicar(
      usuario: context.read<SessaoViewModel>().usuario!,
      empresa: widget.empresa,
      dados: DadosVaga(
        titulo: _titulo.text,
        area: _area ?? '',
        posicoes: int.tryParse(_posicoes.text),
        cidade: _cidade ?? '',
        qualificacao: _qualificacao.text,
        cursos: List.of(_cursos),
      ),
    );
    if (publicou) navegador.pop(true);
  }

  /// RF0015: escolhe entre os cursos já aprovados da área da vaga.
  Future<void> _adicionarCurso() async {
    final viewModel = context.read<NovaVagaViewModel>();
    final opcoes = viewModel.cursosDaArea(_area, _cursos);
    final escolhido = await showModalBottomSheet<Curso>(
      context: context,
      showDragHandle: true,
      builder: (folha) => SafeArea(
        child: opcoes.isEmpty
            ? Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Text(
                  'Ainda não há cursos aprovados na área ${_area ?? ''}. '
                  'Publique a vaga e as oficinas enviam cursos para você aprovar.',
                ),
              )
            : ListView(
                shrinkWrap: true,
                children: [
                  for (final curso in opcoes)
                    ListTile(
                      leading: const Icon(Icons.school_outlined),
                      title: Text(curso.nome),
                      subtitle: Text(
                        '${curso.oficina} · ${curso.cargaHoraria} h',
                      ),
                      onTap: () => Navigator.of(folha).pop(curso),
                    ),
                ],
              ),
      ),
    );
    if (escolhido == null) return;
    viewModel.limparErro(CampoCadastro.cursos);
    setState(() => _cursos.add(escolhido));
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NovaVagaViewModel>();
    final erros = viewModel.erros;
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Nova vaga')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          Text(
            'Campos com * são obrigatórios.',
            style: textos.bodySmall?.copyWith(color: CoresNexo.neutro700),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titulo,
            onChanged: (_) => _limpar(CampoCadastro.titulo),
            textCapitalization: TextCapitalization.sentences,
            maxLength: tamanhoMaximoCargo,
            decoration: InputDecoration(
              labelText: 'Cargo *',
              hintText: 'Ex.: Pintor(a) naval',
              errorText: erros[CampoCadastro.titulo],
              counterText: '',
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: CampoEscolha(
                  key: const Key('campo-area'),
                  rotulo: 'Área *',
                  opcoes: areasVagas,
                  valor: _area,
                  erro: erros[CampoCadastro.area],
                  aoMudar: (area) {
                    _limpar(CampoCadastro.area);
                    setState(() => _area = area);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _posicoes,
                  onChanged: (_) => _limpar(CampoCadastro.posicoes),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Posições *',
                    errorText: erros[CampoCadastro.posicoes],
                    errorMaxLines: 3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          CampoEscolha(
            key: const Key('campo-cidade'),
            rotulo: 'Cidade *',
            opcoes: cidadesAmfri,
            valor: _cidade,
            erro: erros[CampoCadastro.cidade],
            aoMudar: (cidade) {
              _limpar(CampoCadastro.cidade);
              setState(() => _cidade = cidade);
            },
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _qualificacao,
            onChanged: (_) => _limpar(CampoCadastro.qualificacao),
            textCapitalization: TextCapitalization.sentences,
            minLines: 2,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              labelText: 'Qualificação exigida *',
              hintText: 'O que a pessoa precisa saber fazer',
              errorText: erros[CampoCadastro.qualificacao],
              counterText: '',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text('Cursos preferenciais', style: textos.titleMedium),
              ),
              Text(
                '${_cursos.length} de $limiteCursosPorVaga',
                style: textos.labelMedium?.copyWith(
                  color: CoresNexo.primaria500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final curso in _cursos)
                InputChip(
                  label: Text(curso.nome),
                  deleteButtonTooltipMessage: 'Tirar curso',
                  onDeleted: () => setState(() => _cursos.remove(curso)),
                ),
              ActionChip(
                avatar: const Icon(Icons.add, size: 16),
                label: const Text('Adicionar'),
                onPressed: _cursos.length >= limiteCursosPorVaga
                    ? null
                    : _adicionarCurso,
              ),
            ],
          ),
          if (erros[CampoCadastro.cursos] case final erro?) ...[
            const SizedBox(height: 4),
            Text(
              erro,
              style: textos.bodySmall?.copyWith(color: CoresNexo.erro),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Até $limiteCursosPorVaga cursos (RN0006). As oficinas enviam cursos e você aprova.',
            style: textos.bodySmall?.copyWith(color: CoresNexo.neutro700),
          ),
          const SizedBox(height: 20),
          AvisoCadastro(
            texto: _cursos.isEmpty
                ? 'A vaga aparece na pesquisa ao publicar e passa a receber candidaturas depois que você aprovar um curso.'
                : 'Com um curso escolhido, a vaga já começa aceitando candidaturas.',
            icone: Icons.info_outline,
            fundo: CoresNexo.primaria50,
            cor: CoresNexo.primaria500,
          ),
          if (erros.isNotEmpty) ...[
            const SizedBox(height: 16),
            ResumoErros(quantidade: erros.length),
          ],
          if (viewModel.erroGeral case final erro?) ...[
            const SizedBox(height: 16),
            Text(
              erro,
              style: textos.bodyMedium?.copyWith(color: CoresNexo.erro),
            ),
          ],
          const SizedBox(height: 20),
          BotaoCadastro(
            texto: 'Publicar vaga',
            carregando: viewModel.carregando,
            aoTocar: _publicar,
          ),
        ],
      ),
    );
  }
}
