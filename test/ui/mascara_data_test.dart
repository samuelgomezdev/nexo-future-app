import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/ui/mascara_data.dart';

void main() {
  group('Máscara de data dd/mm/aaaa', () {
    String digitar(String texto) => MascaraData()
        .formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
            text: texto,
            selection: TextSelection.collapsed(offset: texto.length),
          ),
        )
        .text;

    test('coloca as barras sozinha enquanto a pessoa digita', () {
      expect(digitar('1'), '1');
      expect(digitar('10'), '10');
      expect(digitar('100'), '10/0');
      expect(digitar('10051'), '10/05/1');
      expect(digitar('10051990'), '10/05/1990');
    });

    test('ignora o que não é número e limita a 8 dígitos', () {
      expect(digitar('10-05-1990'), '10/05/1990');
      expect(digitar('100519901'), '10/05/1990');
    });

    test('deixa o cursor no fim do texto', () {
      final resultado = MascaraData().formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '100519',
          selection: TextSelection.collapsed(offset: 6),
        ),
      );

      expect(resultado.selection.baseOffset, resultado.text.length);
    });
  });
}
