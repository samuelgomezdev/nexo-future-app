import 'package:flutter/material.dart';

import '../tema.dart';
import 'cadastro_empresa_screen.dart';
import 'cadastro_jovem_screen.dart';
import 'cadastro_oficina_screen.dart';

enum _Perfil { jovem, empresa, oficina }

/// C1 do protótipo: cada perfil vê telas diferentes.
class EscolhaPerfilScreen extends StatefulWidget {
  const EscolhaPerfilScreen({super.key});

  @override
  State<EscolhaPerfilScreen> createState() => _EscolhaPerfilScreenState();
}

class _EscolhaPerfilScreenState extends State<EscolhaPerfilScreen> {
  _Perfil _perfil = _Perfil.jovem;

  void _continuar() {
    final tela = switch (_perfil) {
      _Perfil.jovem => const CadastroJovemScreen(),
      _Perfil.empresa => const CadastroEmpresaScreen(),
      _Perfil.oficina => const CadastroOficinaScreen(),
    };
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => tela));
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          Text(
            'Como você vai usar o Nexo Future?',
            style: textos.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha o seu perfil. Cada um vê telas diferentes.',
            style: textos.bodyMedium?.copyWith(color: CoresNexo.neutro700),
          ),
          const SizedBox(height: 20),
          _OpcaoPerfil(
            titulo: 'Sou jovem',
            descricao: 'Quero fazer cursos e me candidatar a vagas.',
            icone: Icons.person_outline,
            selecionado: _perfil == _Perfil.jovem,
            aoTocar: () => setState(() => _perfil = _Perfil.jovem),
          ),
          const SizedBox(height: 12),
          _OpcaoPerfil(
            titulo: 'Sou empresa',
            descricao: 'Quero publicar vagas e aprovar cursos.',
            icone: Icons.apartment_outlined,
            selecionado: _perfil == _Perfil.empresa,
            aoTocar: () => setState(() => _perfil = _Perfil.empresa),
          ),
          const SizedBox(height: 12),
          _OpcaoPerfil(
            titulo: 'Sou oficina',
            descricao: 'Quero oferecer cursos ligados às vagas.',
            icone: Icons.build_outlined,
            selecionado: _perfil == _Perfil.oficina,
            aoTocar: () => setState(() => _perfil = _Perfil.oficina),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: FilledButton(
            onPressed: _continuar,
            child: const Text('Continuar'),
          ),
        ),
      ),
    );
  }
}

class _OpcaoPerfil extends StatelessWidget {
  const _OpcaoPerfil({
    required this.titulo,
    required this.descricao,
    required this.icone,
    required this.selecionado,
    required this.aoTocar,
  });

  final String titulo;
  final String descricao;
  final IconData icone;
  final bool selecionado;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Semantics(
      selected: selecionado,
      button: true,
      child: Material(
        color: selecionado ? CoresNexo.primaria50 : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selecionado ? CoresNexo.primaria500 : CoresNexo.neutro200,
            width: selecionado ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: aoTocar,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: selecionado
                        ? CoresNexo.primaria500
                        : CoresNexo.primaria100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icone,
                    color: selecionado ? Colors.white : CoresNexo.primaria500,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo, style: textos.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        descricao,
                        style: textos.bodyMedium?.copyWith(
                          color: CoresNexo.neutro700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  selecionado
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selecionado
                      ? CoresNexo.primaria500
                      : CoresNexo.neutro300,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
