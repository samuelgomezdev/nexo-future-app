import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/ui/mascara_cnpj.dart';

void main() {
  group('Máscara de CNPJ 00.000.000/0000-00', () {
    String digitar(String texto) => MascaraCnpj()
        .formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
            text: texto,
            selection: TextSelection.collapsed(offset: texto.length),
          ),
        )
        .text;

    test('coloca pontos, barra e traço enquanto a pessoa digita', () {
      expect(digitar('11'), '11');
      expect(digitar('112'), '11.2');
      expect(digitar('112223'), '11.222.3');
      expect(digitar('112223330'), '11.222.333/0');
      expect(digitar('1122233300018'), '11.222.333/0001-8');
      expect(digitar('11222333000181'), '11.222.333/0001-81');
    });

    test('ignora o que não é número e limita a 14 dígitos', () {
      expect(digitar('11.222.333/0001-81'), '11.222.333/0001-81');
      expect(digitar('112223330001819'), '11.222.333/0001-81');
    });
  });
}
