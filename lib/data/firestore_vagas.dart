import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/models/curso.dart';
import 'mapa_vagas.dart';

/// Guarda vagas e cursos no Cloud Firestore (coleções vagas e cursos).
/// As regras de segurança estão em firestore.rules.
class FirestoreVagas implements RepositorioVagas {
  FirestoreVagas([FirebaseFirestore? banco])
    : _banco = banco ?? FirebaseFirestore.instance;

  final FirebaseFirestore _banco;

  CollectionReference<Map<String, dynamic>> get _vagas =>
      _banco.collection('vagas');
  CollectionReference<Map<String, dynamic>> get _cursos =>
      _banco.collection('cursos');

  @override
  String novoId() => _vagas.doc().id;

  @override
  Future<List<Vaga>> listarVagas() async {
    final consulta = await _vagas.orderBy('criadoEm', descending: true).get();
    return [for (final doc in consulta.docs) vagaDoMapa(doc.id, doc.data())];
  }

  @override
  Future<Vaga?> buscarVaga(String id) async {
    final doc = await _vagas.doc(id).get();
    final dados = doc.data();
    return dados == null ? null : vagaDoMapa(id, dados);
  }

  @override
  Future<List<Vaga>> vagasDaEmpresa(String empresaId) async {
    final consulta = await _vagas
        .where('empresaId', isEqualTo: empresaId)
        .get();
    return [for (final doc in consulta.docs) vagaDoMapa(doc.id, doc.data())];
  }

  @override
  Future<void> salvarVaga(Vaga vaga) => _vagas.doc(vaga.id).set({
    ...vagaParaMapa(vaga),
    'criadoEm': FieldValue.serverTimestamp(),
  });

  @override
  Future<void> salvarCurso(CursoOficina curso) => _cursos.doc(curso.id).set({
    ...cursoParaMapa(curso),
    'criadoEm': FieldValue.serverTimestamp(),
  });

  @override
  Future<List<CursoOficina>> cursosDaOficina(String oficinaId) async {
    final consulta = await _cursos
        .where('oficinaId', isEqualTo: oficinaId)
        .get();
    return [for (final doc in consulta.docs) cursoDoMapa(doc.id, doc.data())];
  }

  @override
  Future<List<CursoOficina>> cursosParaAprovar(String empresaId) async {
    final consulta = await _cursos
        .where('empresaId', isEqualTo: empresaId)
        .where('situacao', isEqualTo: SituacaoCurso.emAnalise.name)
        .get();
    return [for (final doc in consulta.docs) cursoDoMapa(doc.id, doc.data())];
  }

  /// A decisão do curso e o vínculo na vaga são gravados juntos.
  @override
  Future<void> decidirCurso(CursoOficina curso, {Vaga? vaga}) async {
    final lote = _banco.batch();
    lote.update(_cursos.doc(curso.id), {'situacao': curso.situacao.name});
    if (vaga != null) {
      final mapa = vagaParaMapa(vaga);
      lote.update(_vagas.doc(vaga.id), {
        'cursos': mapa['cursos'],
        'situacao': mapa['situacao'],
      });
    }
    await lote.commit();
  }
}
