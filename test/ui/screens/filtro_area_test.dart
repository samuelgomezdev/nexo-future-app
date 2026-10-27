import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/ui/app.dart';
import 'package:nexo_future_app/ui/tema.dart';

void main() {
  group('Filtros de área na lista de vagas', () {
    Color? corDoRotulo(WidgetTester tester, Finder chip) {
      final rotulo = tester.widget<RichText>(
        find.descendant(of: chip, matching: find.byType(RichText)).first,
      );
      return rotulo.text.style?.color;
    }

    testWidgets('a área não selecionada tem o texto legível', (tester) async {
      await tester.pumpWidget(const NexoFutureApp());
      await tester.pumpAndSettle();

      final chips = find.byType(ChoiceChip);

      expect(corDoRotulo(tester, chips.at(0)), Colors.white);
      expect(corDoRotulo(tester, chips.at(1)), CoresNexo.neutro700);
    });
  });
}
