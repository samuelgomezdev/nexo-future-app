import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Gestos dos testes de integração: no celular, os formulários rolam e o
// teclado cobre parte da tela, então cada toque leva o alvo para a vista.

Future<void> tocar(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

Future<void> digitar(WidgetTester tester, String rotulo, String texto) async {
  final campo = find.widgetWithText(TextField, rotulo);
  await tester.ensureVisible(campo);
  await tester.enterText(campo, texto);
  await tester.pumpAndSettle();
}

Future<void> escolher(WidgetTester tester, String chave, String opcao) async {
  await tocar(tester, find.byKey(Key(chave)));
  await tester.tap(find.text(opcao).last);
  await tester.pumpAndSettle();
}

Future<void> entrar(WidgetTester tester, String email) async {
  await tocar(tester, find.byKey(const Key('botao-entrar')));
  await digitar(tester, 'E-mail', email);
  await digitar(tester, 'Senha', 'senha-certa');
  await tocar(tester, find.widgetWithText(FilledButton, 'Entrar'));
}

Future<void> sair(WidgetTester tester) async {
  await tocar(tester, find.byTooltip('Sair'));
}
