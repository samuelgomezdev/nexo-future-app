final _formatoEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

bool emailValido(String email) => _formatoEmail.hasMatch(email.trim());

String somenteDigitos(String texto) => texto.replaceAll(RegExp(r'\D'), '');

/// Confere os dois dígitos verificadores do CNPJ (módulo 11).
bool cnpjValido(String cnpj) {
  final digitos = somenteDigitos(cnpj);
  if (digitos.length != 14) return false;
  if (RegExp(r'^(\d)\1*$').hasMatch(digitos)) return false;

  final numeros = digitos.split('').map(int.parse).toList();
  int digitoVerificador(int tamanho) {
    final pesos = tamanho == 12
        ? [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
        : [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    var soma = 0;
    for (var i = 0; i < tamanho; i++) {
      soma += numeros[i] * pesos[i];
    }
    final resto = soma % 11;
    return resto < 2 ? 0 : 11 - resto;
  }

  return digitoVerificador(12) == numeros[12] &&
      digitoVerificador(13) == numeros[13];
}

/// Nome e sobrenome: pelo menos duas palavras.
bool temSobrenome(String nome) => nome.trim().split(RegExp(r'\s+')).length >= 2;
