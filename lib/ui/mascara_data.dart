import 'package:flutter/services.dart';

/// Mostra a data como dd/mm/aaaa.
String formatarDataBr(DateTime data) {
  String doisDigitos(int n) => n.toString().padLeft(2, '0');
  return '${doisDigitos(data.day)}/${doisDigitos(data.month)}/${data.year}';
}

/// Coloca as barras de dd/mm/aaaa enquanto a pessoa digita só os números.
class MascaraData extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue anterior,
    TextEditingValue novo,
  ) {
    final digitos = novo.text.replaceAll(RegExp(r'\D'), '');
    final limitados = digitos.length > 8 ? digitos.substring(0, 8) : digitos;
    final texto = StringBuffer();
    for (var i = 0; i < limitados.length; i++) {
      if (i == 2 || i == 4) texto.write('/');
      texto.write(limitados[i]);
    }
    final resultado = texto.toString();
    return TextEditingValue(
      text: resultado,
      selection: TextSelection.collapsed(offset: resultado.length),
    );
  }
}
