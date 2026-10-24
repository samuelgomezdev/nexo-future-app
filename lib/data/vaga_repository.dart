import '../domain/models/vaga.dart';

/// RNF0002: a pesquisa devolve páginas de 15 vagas.
const tamanhoPagina = 15;

class VagaRepository {
  VagaRepository(List<Vaga> vagas) : _vagas = List.unmodifiable(vagas);

  final List<Vaga> _vagas;

  /// Filtra por texto no título (sem diferenciar maiúsculas e acentos) e por
  /// área. A primeira página é a 1.
  List<Vaga> pesquisar({String texto = '', String? area, int pagina = 1}) {
    final termo = _normalizar(texto.trim());
    final filtradas = _vagas.where((v) {
      final casaTexto = termo.isEmpty || _normalizar(v.titulo).contains(termo);
      final casaArea = area == null || v.area == area;
      return casaTexto && casaArea;
    });
    return filtradas
        .skip((pagina - 1) * tamanhoPagina)
        .take(tamanhoPagina)
        .toList();
  }
}

const _comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
const _semAcento = 'aaaaaeeeeiiiiooooouuuucn';

String _normalizar(String texto) {
  final minusculo = texto.toLowerCase();
  final buffer = StringBuffer();
  for (final letra in minusculo.split('')) {
    final i = _comAcento.indexOf(letra);
    buffer.write(i == -1 ? letra : _semAcento[i]);
  }
  return buffer.toString();
}
