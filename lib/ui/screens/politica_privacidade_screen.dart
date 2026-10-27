import 'package:flutter/material.dart';

import '../tema.dart';

/// Política de Privacidade do MVP, em linguagem simples (LGPD).
class PoliticaPrivacidadeScreen extends StatelessWidget {
  const PoliticaPrivacidadeScreen({super.key});

  static const _secoes = [
    (
      'Quais dados pedimos',
      'Nome, e-mail, senha, cidade e data de nascimento. Só isso: não pedimos '
          'CPF, RG, endereço nem foto. A senha fica guardada de forma '
          'protegida pelo Firebase, e nem a equipe consegue vê-la.',
    ),
    (
      'Para que usamos',
      'Para você entrar no app, ver vagas e cursos da sua região e se '
          'candidatar. A data de nascimento serve para saber se você precisa '
          'da autorização de um responsável.',
    ),
    (
      'Quem vê seus dados',
      'Só a empresa da vaga em que você se candidatar vê seu nome, cidade e '
          'e-mail. Não vendemos nem repassamos seus dados a mais ninguém.',
    ),
    (
      'Menores de 18 anos',
      'Quem tem de 12 a 17 anos só se cadastra com a autorização de um '
          'responsável. Menores de 12 anos não podem usar o app.',
    ),
    (
      'Onde os dados ficam',
      'No Firebase (Google), em servidores em São Paulo, com acesso '
          'restrito à sua própria conta.',
    ),
    (
      'Seus direitos',
      'Você pode pedir para ver, corrigir ou apagar seus dados a qualquer '
          'momento, falando com a equipe do projeto Nexo Future (ADS Univali). '
          'Ao apagar a conta, seus dados saem do app.',
    ),
    (
      'Sobre este app',
      'O Nexo Future é um projeto acadêmico em fase de testes (MVP). Os dados '
          'das contas de teste são apagados ao final da validação.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Política de Privacidade')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          for (final (titulo, texto) in _secoes) ...[
            Text(titulo, style: textos.titleMedium),
            const SizedBox(height: 4),
            Text(
              texto,
              style: textos.bodyLarge?.copyWith(color: CoresNexo.neutro700),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}
