import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nexo_future_app/domain/models/curso.dart';
import 'package:nexo_future_app/domain/models/empresa.dart';
import 'package:nexo_future_app/domain/models/jovem.dart';
import 'package:nexo_future_app/domain/models/oficina.dart';
import 'package:nexo_future_app/ui/app.dart';

import '../test/apoio/autenticacao_falsa.dart';
import '../test/apoio/perfis_falsos.dart';
import '../test/apoio/vagas_falsas.dart';
import 'apoio_integracao.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // RF0004, RF0005, RF0015, RF0007 e RF0008: o caminho completo, até a vaga
  // lotar, com contas e
  // dados fictícios e o Firebase substituído por versões em memória.
  testWidgets('a empresa publica a vaga, a oficina propõe o curso, o '
      'recrutador aprova e o jovem se candidata', (tester) async {
    const empresa = 'rh@fozazul.example.com';
    const oficina = 'contato@maosdoporto.example.com';
    const jovem = 'carla.lima@example.com';

    final auth = AutenticacaoFalsa();
    for (final email in [empresa, oficina, jovem]) {
      auth.contas[email] = (senha: 'senha-certa', emailVerificado: true);
    }
    final perfis = PerfisFalsos();
    perfis.empresas['uid-$empresa'] = PerfilEmpresa(
      id: 'uid-$empresa',
      nome: 'Estaleiro Foz Azul',
      cnpj: '11222333000181',
      setor: 'Naval',
      recrutador: 'Marcos Pereira',
      email: empresa,
      cidade: 'Itajaí',
      aceitePoliticaEm: DateTime(2026, 11, 1),
    );
    perfis.oficinas['uid-$oficina'] = PerfilOficina(
      id: 'uid-$oficina',
      nome: 'Oficina Escola Mãos do Porto',
      cnpj: '11222333000181',
      gestor: 'Rita Moraes',
      email: oficina,
      cidade: 'Itajaí',
      alvara: Alvara(numero: 'AE-2026-0042', validade: DateTime(2099, 3, 1)),
      aceitePoliticaEm: DateTime(2026, 11, 1),
    );
    perfis.jovens['uid-$jovem'] = PerfilJovem(
      id: 'uid-$jovem',
      nome: 'Carla Lima',
      email: jovem,
      cidade: 'Navegantes',
      dataNascimento: DateTime(2004, 3, 2),
      autorizacaoResponsavel: false,
      aceitePoliticaEm: DateTime(2026, 11, 1),
    );
    final vagas = VagasFalsas();

    await tester.pumpWidget(
      NexoFutureApp(autenticacao: auth, perfis: perfis, vagas: vagas),
    );
    await tester.pumpAndSettle();

    // 1. A empresa publica a vaga (E2), que nasce aberta.
    await entrar(tester, empresa);
    await tocar(tester, find.text('Nova vaga'));
    await digitar(tester, 'Cargo *', 'Pintor(a) naval');
    await digitar(tester, 'Posições *', '1');
    await digitar(
      tester,
      'Qualificação exigida *',
      'Preparo de superfície e pintura de cascos.',
    );
    await tocar(tester, find.text('Publicar vaga'));
    expect(find.text('Aguardando cursos'), findsOneWidget);
    expect(vagas.vagas.values.single.situacao, SituacaoVaga.aberta);
    await sair(tester);

    // 2. A oficina com alvará propõe um curso para a vaga (O2).
    await entrar(tester, oficina);
    await tocar(tester, find.text('Novo curso'));
    await digitar(tester, 'Nome do curso *', 'Pintura naval');
    await escolher(
      tester,
      'campo-vaga',
      'Pintor(a) naval · Estaleiro Foz Azul',
    );
    await digitar(tester, 'Carga horária *', '32');
    await digitar(tester, 'Vagas na turma *', '15');
    await tocar(tester, find.text('Publicar curso'));
    expect(find.text('Em análise'), findsOneWidget);
    await sair(tester);

    // 3. O recrutador aprova o curso (E3) e a vaga passa a aceitar candidaturas.
    await entrar(tester, empresa);
    await tocar(tester, find.text('Pintura naval'));
    await tocar(tester, find.widgetWithText(FilledButton, 'Aprovar curso'));
    expect(find.text('Aceitando candidaturas'), findsOneWidget);
    expect(vagas.vagas.values.single.situacao, SituacaoVaga.aguardandoIngresso);
    await sair(tester);

    // 4. O jovem encontra a vaga na pesquisa e se candidata.
    await entrar(tester, jovem);
    await tester.enterText(find.byType(TextField), 'pintor');
    await tester.pumpAndSettle();
    await tocar(tester, find.text('Pintor(a) naval').first);
    expect(find.text('Pintura naval'), findsOneWidget);
    await tocar(tester, find.text('Candidatar-se'));

    expect(find.text('Candidatura enviada'), findsOneWidget);
    // A vaga tinha 1 posição: a candidatura a deixou lotada.
    expect(vagas.vagas.values.single.situacao, SituacaoVaga.lotada);
    expect(vagas.vagas.values.single.candidaturas, 1);
    expect(
      find.text('Você se candidatou à vaga Pintor(a) naval.'),
      findsOneWidget,
    );
  });
}
