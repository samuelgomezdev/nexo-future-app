import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/domain/models/empresa.dart';
import 'package:nexo_future_app/domain/models/oficina.dart';
import 'package:nexo_future_app/ui/app.dart';

import 'autenticacao_falsa.dart';
import 'perfis_falsos.dart';
import 'vagas_falsas.dart';

/// Conta de teste da AutenticacaoFalsa, com o e-mail já confirmado.
const emailTeste = 'ana@email.com';
const idTeste = 'uid-$emailTeste';

PerfilEmpresa empresaDeTeste({String id = idTeste}) => PerfilEmpresa(
  id: id,
  nome: 'Estaleiro Foz Azul',
  cnpj: '11222333000181',
  setor: 'Naval',
  recrutador: 'Marcos Pereira',
  email: emailTeste,
  cidade: 'Itajaí',
  aceitePoliticaEm: DateTime(2026, 11, 1),
);

PerfilOficina oficinaDeTeste({Alvara? alvara, String id = idTeste}) =>
    PerfilOficina(
      id: id,
      nome: 'Oficina Escola Mãos do Porto',
      cnpj: '11222333000181',
      gestor: 'Rita Moraes',
      email: emailTeste,
      cidade: 'Itajaí',
      alvara: alvara,
      aceitePoliticaEm: DateTime(2026, 11, 1),
    );

final alvaraEmDia = Alvara(
  numero: 'AE-2026-0042',
  validade: DateTime(2099, 3, 1),
);

/// Abre o app com o Firebase falso e entra com a conta de teste.
Future<void> entrarNoApp(
  WidgetTester tester, {
  required PerfisFalsos perfis,
  required VagasFalsas vagas,
  AutenticacaoFalsa? autenticacao,
  String email = emailTeste,
}) async {
  await tester.pumpWidget(
    NexoFutureApp(
      autenticacao: autenticacao ?? AutenticacaoFalsa(),
      perfis: perfis,
      vagas: vagas,
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('botao-entrar')));
  await tester.pumpAndSettle();
  await tester.enterText(find.widgetWithText(TextField, 'E-mail'), email);
  await tester.enterText(
    find.widgetWithText(TextField, 'Senha'),
    'senha-certa',
  );
  await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
  await tester.pumpAndSettle();
}

/// Escolhe uma opção numa lista de opções fixas, como a cidade.
Future<void> escolherOpcao(
  WidgetTester tester,
  String chave,
  String opcao,
) async {
  await tester.tap(find.byKey(Key(chave)));
  await tester.pumpAndSettle();
  await tester.tap(find.text(opcao).last);
  await tester.pumpAndSettle();
}
