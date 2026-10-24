// Resume o coverage/lcov.info por arquivo e por camada.
// Uso: flutter test --coverage && dart run tool/cobertura.dart
import 'dart:io';

void main() {
  final arquivo = File('coverage/lcov.info');
  if (!arquivo.existsSync()) {
    stderr.writeln('Rode antes: flutter test --coverage');
    exit(1);
  }

  final linhas = <String, (int cobertas, int total)>{};
  String? atual;
  var total = 0;
  for (final linha in arquivo.readAsLinesSync()) {
    if (linha.startsWith('SF:')) {
      atual = linha.substring(3).replaceAll(r'\', '/');
      atual = atual.substring(atual.indexOf('lib/'));
    } else if (linha.startsWith('LF:')) {
      total = int.parse(linha.substring(3));
    } else if (linha.startsWith('LH:') && atual != null) {
      linhas[atual] = (int.parse(linha.substring(3)), total);
    }
  }

  String porcento(int cobertas, int total) =>
      '${(100 * cobertas / total).toStringAsFixed(1)}%'.padLeft(7);

  final nomes = linhas.keys.toList()..sort();
  stdout.writeln('Cobertura por arquivo');
  for (final nome in nomes) {
    final (cobertas, total) = linhas[nome]!;
    stdout.writeln(
      '  ${nome.padRight(48)} ${'$cobertas/$total'.padLeft(7)} '
      '${porcento(cobertas, total)}',
    );
  }

  stdout.writeln('\nCobertura por camada');
  for (final camada in ['lib/domain', 'lib/data', 'lib/ui', 'lib']) {
    var cobertas = 0;
    var totalCamada = 0;
    for (final MapEntry(:key, :value) in linhas.entries) {
      if (key.startsWith(camada)) {
        cobertas += value.$1;
        totalCamada += value.$2;
      }
    }
    stdout.writeln(
      '  ${camada.padRight(48)} ${'$cobertas/$totalCamada'.padLeft(7)} '
      '${porcento(cobertas, totalCamada)}',
    );
  }
}
