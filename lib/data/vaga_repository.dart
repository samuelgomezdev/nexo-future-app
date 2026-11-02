import '../domain/models/curso.dart';

/// RNF0002: a pesquisa devolve páginas de 15 vagas.
const tamanhoPagina = 15;

class VagaRepository {
  /// [vagas] são as fixas (o seed fictício); com a [fonte], as vagas
  /// publicadas no Firestore entram na frente delas a cada [atualizar].
  VagaRepository(List<Vaga> vagas, {this._fonte})
    : _fixas = List.unmodifiable(vagas),
      _vagas = List.unmodifiable(vagas);

  final List<Vaga> _fixas;
  final RepositorioVagas? _fonte;
  List<Vaga> _vagas;

  /// Busca de novo as vagas publicadas. Sem internet, a falha sobe e a
  /// pesquisa continua com as vagas que já tinha.
  Future<void> atualizar() async {
    final fonte = _fonte;
    if (fonte == null) return;
    final publicadas = await fonte.listarVagas();
    _vagas = List.unmodifiable([...publicadas, ..._fixas]);
  }

  Vaga? buscarPorId(String id) {
    for (final vaga in _vagas) {
      if (vaga.id == id) return vaga;
    }
    return null;
  }

  /// Áreas das vagas, sem repetir e em ordem alfabética.
  List<String> get areas =>
      (_vagas.map((v) => v.area).toSet().toList()..sort());

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
