import 'package:flutter/services.dart';

/// Coloca a pontuação de 00.000.000/0000-00 enquanto a pessoa digita só os números.
class MascaraCnpj extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue anterior,
    TextEditingValue novo,
  ) {
    final digitos = novo.text.replaceAll(RegExp(r'\D'), '');
    final limitados = digitos.length > 14 ? digitos.substring(0, 14) : digitos;
    const separadores = {2: '.', 5: '.', 8: '/', 12: '-'};
    final texto = StringBuffer();
    for (var i = 0; i < limitados.length; i++) {
      if (separadores[i] case final separador?) texto.write(separador);
      texto.write(limitados[i]);
    }
    final resultado = texto.toString();
    return TextEditingValue(
      text: resultado,
      selection: TextSelection.collapsed(offset: resultado.length),
    );
  }
}
