import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../domain/models/cadastro.dart';
import '../../domain/models/curso.dart';
import '../../domain/models/oficina.dart';
import '../../domain/regras/alvara_oficina.dart';
import '../../domain/regras/cadastro_curso.dart';
import '../tema.dart';
import '../viewmodels/novo_curso_viewmodel.dart';
import '../viewmodels/sessao_viewmodel.dart';
import 'componentes_cadastro.dart';

/// O2 do protótipo: a oficina monta um curso para uma vaga (RF0005 e RF0015).
/// Devolve o curso salvo, publicado ou em rascunho.
class NovoCursoScreen extends StatelessWidget {
  const NovoCursoScreen({super.key, required this.oficina, this.hoje});

  final PerfilOficina oficina;

  /// Data usada para conferir a validade do alvará; nos testes, fixa.
  final DateTime? hoje;

  @override
  Widget build(BuildContext context) {
    final vagas = context.read<RepositorioVagas>();
    return ChangeNotifierProvider(
      create: (_) => NovoCursoViewModel(
        PublicarCurso(vagas, relogio: hoje == null ? null : () => hoje!),
        vagas,
      )..carregarVagas(),
      child: _FormularioCurso(oficina: oficina, hoje: hoje),
    );
  }
}

class _FormularioCurso extends StatefulWidget {
  const _FormularioCurso({required this.oficina, this.hoje});

  final PerfilOficina oficina;
  final DateTime? hoje;

  @override
  State<_FormularioCurso> createState() => _FormularioCursoState();
}

class _FormularioCursoState extends State<_FormularioCurso> {
  final _nome = TextEditingController();
  final _cargaHoraria = TextEditingController();
  final _vagasTurma = TextEditingController();
  final _descricao = TextEditingController();
  Vaga? _vaga;

  @override
  void dispose() {
    _nome.dispose();
    _cargaHoraria.dispose();
    _vagasTurma.dispose();
    _descricao.dispose();
    super.dispose();
  }

  void _limpar(CampoCadastro campo) =>
      context.read<NovoCursoViewModel>().limparErro(campo);

  Future<void> _salvar({required bool rascunho}) async {
    final viewModel = context.read<NovoCursoViewModel>();
    final navegador = Navigator.of(context);
    final salvou = await viewModel.publicar(
      usuario: context.read<SessaoViewModel>().usuario!,
      oficina: widget.oficina,
      rascunho: rascunho,
      dados: DadosCurso(
        nome: _nome.text,
        vaga: _vaga,
        cargaHoraria: int.tryParse(_cargaHoraria.text),
        vagasTurma: int.tryParse(_vagasTurma.text),
        descricao: _descricao.text,
      ),
    );
    if (salvou) navegador.pop(viewModel.curso);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NovoCursoViewModel>();
    final erros = viewModel.erros;
    final textos = Theme.of(context).textTheme;
    final podePublicar = podePublicarCurso(
      widget.oficina.oficina,
      hoje: widget.hoje ?? DateTime.now(),
    );
    final vaga = _vaga;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Novo curso')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          Text(
            'Campos com * são obrigatórios.',
            style: textos.bodySmall?.copyWith(color: CoresNexo.neutro700),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nome,
            onChanged: (_) => _limpar(CampoCadastro.nome),
            textCapitalization: TextCapitalization.sentences,
            maxLength: tamanhoMaximoNomeCurso,
            decoration: InputDecoration(
              labelText: 'Nome do curso *',
              errorText: erros[CampoCadastro.nome],
              counterText: '',
            ),
          ),
          const SizedBox(height: 14),
          if (viewModel.vagasDisponiveis.isEmpty && viewModel.erroGeral == null)
            const AvisoCadastro(
              texto: 'Ainda não há vagas recebendo cursos. Volte quando as empresas publicarem vagas.',
              icone: Icons.info_outline,
              fundo: CoresNexo.primaria50,
              cor: CoresNexo.primaria500,
            )
          else
            DropdownButtonFormField<Vaga>(
              key: const Key('campo-vaga'),
              initialValue: vaga,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Vaga ligada ao curso *',
                helperText: vaga == null ? null : 'Área do curso: ${vaga.area}',
                errorText: erros[CampoCadastro.vaga],
                errorMaxLines: 2,
              ),
              items: [
                for (final opcao in viewModel.vagasDisponiveis)
                  DropdownMenuItem(
                    value: opcao,
                    child: Text(
                      '${opcao.titulo} · ${opcao.empresa}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (escolhida) {
                _limpar(CampoCadastro.vaga);
                setState(() => _vaga = escolhida);
              },
            ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _CampoNumero(
                  controller: _cargaHoraria,
                  rotulo: 'Carga horária *',
                  sufixo: 'h',
                  erro: erros[CampoCadastro.cargaHoraria],
                  aoMudar: () => _limpar(CampoCadastro.cargaHoraria),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CampoNumero(
                  controller: _vagasTurma,
                  rotulo: 'Vagas na turma *',
                  erro: erros[CampoCadastro.vagasTurma],
                  aoMudar: () => _limpar(CampoCadastro.vagasTurma),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _descricao,
            onChanged: (_) => _limpar(CampoCadastro.descricao),
            textCapitalization: TextCapitalization.sentences,
            minLines: 2,
            maxLines: 4,
            maxLength: tamanhoMaximoDescricao,
            decoration: InputDecoration(
              labelText: 'Descrição',
              hintText: 'Conte o que o aluno vai aprender',
              errorText: erros[CampoCadastro.descricao],
              counterText: '',
            ),
          ),
          const SizedBox(height: 20),
          if (podePublicar)
            const AvisoCadastro(
              texto: 'O recrutador da vaga analisa o curso. Depois de aprovado, ele aparece na vaga para os jovens.',
              icone: Icons.info_outline,
              fundo: CoresNexo.primaria50,
              cor: CoresNexo.primaria500,
            )
          else
            const AvisoCadastro(
              texto: 'Para publicar, sua oficina precisa do alvará de ensino em dia (RN0003). O curso fica salvo como rascunho.',
              icone: Icons.error_outline,
              fundo: CoresNexo.erroFundo,
              cor: CoresNexo.erro,
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
          FilledButton(
            onPressed: podePublicar && !viewModel.carregando
                ? () => _salvar(rascunho: false)
                : null,
            child: viewModel.carregando
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Publicar curso'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: viewModel.carregando
                ? null
                : () => _salvar(rascunho: true),
            child: const Text('Salvar rascunho'),
          ),
        ],
      ),
    );
  }
}

class _CampoNumero extends StatelessWidget {
  const _CampoNumero({
    required this.controller,
    required this.rotulo,
    required this.aoMudar,
    this.sufixo,
    this.erro,
  });

  final TextEditingController controller;
  final String rotulo;
  final String? sufixo;
  final String? erro;
  final VoidCallback aoMudar;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: (_) => aoMudar(),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      decoration: InputDecoration(
        labelText: rotulo,
        suffixText: sufixo,
        errorText: erro,
        errorMaxLines: 3,
      ),
    );
  }
}
