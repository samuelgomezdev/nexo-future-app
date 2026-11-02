import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nexo_future_app/ui/app.dart';

import '../test/apoio/autenticacao_falsa.dart';
import '../test/apoio/perfis_falsos.dart';
import '../test/apoio/vagas_falsas.dart';
import 'apoio_integracao.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // RF0001, RF0016, RN0001 e RF0019, com contas e dados fictícios e o
  // Firebase substituído por versões em memória.
  testWidgets('a empresa se cadastra, confirma o e-mail, entra e chega ao '
      'painel do recrutador', (tester) async {
    final auth = AutenticacaoFalsa();
    final perfis = PerfisFalsos();
    const email = 'rh@fozazul.example.com';

    await tester.pumpWidget(
      NexoFutureApp(autenticacao: auth, perfis: perfis, vagas: VagasFalsas()),
    );
    await tester.pumpAndSettle();

    // Cadastro da empresa em 2 etapas (protótipo C3).
    await tocar(tester, find.byKey(const Key('botao-entrar')));
    await tocar(tester, find.text('Cadastre-se'));
    await tocar(tester, find.text('Sou empresa'));
    await tocar(tester, find.text('Continuar'));
    await digitar(tester, 'Razão social *', 'Estaleiro Foz Azul Ltda.');
    await digitar(tester, 'CNPJ *', '11222333000181');
    await escolher(tester, 'campo-setor', 'Naval');
    await digitar(tester, 'E-mail do recrutador *', email);
    await tocar(tester, find.text('Próxima etapa'));
    await digitar(tester, 'Nome do recrutador *', 'Marcos Pereira');
    await escolher(tester, 'campo-cidade', 'Itajaí');
    await digitar(tester, 'Senha *', 'senha-certa');
    await tocar(tester, find.text('Li e aceito a Política de Privacidade'));
    await tocar(tester, find.text('Criar conta'));

    expect(find.text('Confirme seu e-mail'), findsOneWidget);
    expect(auth.confirmacoesEnviadas, [email]);
    expect(perfis.empresas.values.single.nome, 'Estaleiro Foz Azul Ltda.');

    // RN0001: antes de confirmar o e-mail, não entra.
    await tocar(tester, find.text('Já confirmei'));
    await digitar(tester, 'E-mail', email);
    await digitar(tester, 'Senha', 'senha-certa');
    await tocar(tester, find.widgetWithText(FilledButton, 'Entrar'));
    expect(find.text('Confirme seu e-mail'), findsOneWidget);

    // Depois de tocar no link do e-mail, entra e vai para o painel (RF0019).
    auth.contas[email] = (senha: 'senha-certa', emailVerificado: true);
    await tocar(tester, find.text('Já confirmei'));
    await digitar(tester, 'E-mail', email);
    await digitar(tester, 'Senha', 'senha-certa');
    await tocar(tester, find.widgetWithText(FilledButton, 'Entrar'));

    expect(find.text('Estaleiro Foz Azul Ltda.'), findsOneWidget);
    expect(find.text('Suas vagas'), findsOneWidget);
    expect(find.text('Nova vaga'), findsOneWidget);
  });
}
