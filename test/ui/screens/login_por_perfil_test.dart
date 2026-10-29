import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/domain/models/empresa.dart';
import 'package:nexo_future_app/domain/models/jovem.dart';
import 'package:nexo_future_app/domain/models/oficina.dart';
import 'package:nexo_future_app/ui/app.dart';

import '../../apoio/autenticacao_falsa.dart';
import '../../apoio/perfis_falsos.dart';
import '../../apoio/tela_alta.dart';

void main() {
  // RF0019: o login abre as telas do perfil de quem entrou.
  group('Login por perfil', () {
    const id = 'uid-ana@email.com';
    late PerfisFalsos perfis;

    setUp(() {
      perfis = PerfisFalsos();
      usarTelaAlta();
    });
    tearDown(restaurarTela);

    PerfilOficina oficina({Alvara? alvara}) => PerfilOficina(
      id: id,
      nome: 'Oficina Escola Porto Novo',
      cnpj: '11222333000181',
      gestor: 'Rita Moraes',
      email: 'ana@email.com',
      cidade: 'Itajaí',
      alvara: alvara,
      aceitePoliticaEm: DateTime(2026, 10, 29),
    );

    Future<void> entrar(WidgetTester tester) async {
      await tester.pumpWidget(
        NexoFutureApp(autenticacao: AutenticacaoFalsa(), perfis: perfis),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('botao-entrar')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'E-mail'),
        'ana@email.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Senha'),
        'senha-certa',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
      await tester.pumpAndSettle();
    }

    testWidgets('a empresa entra no painel do recrutador', (tester) async {
      perfis.empresas[id] = PerfilEmpresa(
        id: id,
        nome: 'Estaleiro Foz Azul Ltda.',
        cnpj: '11222333000181',
        setor: 'Naval',
        recrutador: 'Marcos Pereira',
        email: 'ana@email.com',
        cidade: 'Itajaí',
        aceitePoliticaEm: DateTime(2026, 10, 29),
      );

      await entrar(tester);

      expect(find.text('Estaleiro Foz Azul Ltda.'), findsOneWidget);
      expect(
        find.text('Painel do recrutador · Naval · Itajaí'),
        findsOneWidget,
      );
      expect(find.text('Suas vagas'), findsOneWidget);
      expect(find.text('Você ainda não publicou vagas.'), findsOneWidget);
      expect(find.text('Vagas'), findsNothing);
    });

    testWidgets('a oficina com alvará em dia pode publicar cursos', (
      tester,
    ) async {
      perfis.oficinas[id] = oficina(
        alvara: Alvara(numero: 'AE-2026-0042', validade: DateTime(2099, 3, 1)),
      );

      await entrar(tester);

      expect(find.text('Oficina Escola Porto Novo'), findsOneWidget);
      expect(find.text('Oficina escola · Itajaí'), findsOneWidget);
      expect(
        find.text(
          'Alvará de ensino em dia, válido até 01/03/2099. Sua oficina pode publicar cursos.',
        ),
        findsOneWidget,
      );
      expect(find.text('Seus cursos'), findsOneWidget);
    });

    testWidgets('a oficina sem alvará ainda não publica cursos', (
      tester,
    ) async {
      perfis.oficinas[id] = oficina();

      await entrar(tester);

      expect(
        find.text(
          'Sem o alvará de ensino em dia, sua oficina ainda não publica cursos (RN0003).',
        ),
        findsOneWidget,
      );
    });

    testWidgets('a oficina com alvará vencido também não publica', (
      tester,
    ) async {
      perfis.oficinas[id] = oficina(
        alvara: Alvara(numero: 'AE-2019-0001', validade: DateTime(2020, 1, 1)),
      );

      await entrar(tester);

      expect(
        find.text(
          'O alvará de ensino venceu em 01/01/2020. Envie o alvará renovado para publicar cursos.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('o jovem entra na lista de vagas', (tester) async {
      perfis.jovens[id] = PerfilJovem(
        id: id,
        nome: 'Ana Souza',
        email: 'ana@email.com',
        cidade: 'Itajaí',
        dataNascimento: DateTime(2000, 5, 10),
        autorizacaoResponsavel: false,
        aceitePoliticaEm: DateTime(2026, 10, 29),
      );

      await entrar(tester);

      expect(find.text('Vagas'), findsOneWidget);
    });
  });
}
