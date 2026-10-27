import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/models/jovem.dart';

/// Guarda os perfis no Cloud Firestore, um documento por usuário.
class FirestorePerfis implements RepositorioPerfis {
  FirestorePerfis([FirebaseFirestore? banco])
    : _banco = banco ?? FirebaseFirestore.instance;

  final FirebaseFirestore _banco;

  @override
  Future<void> salvarJovem(PerfilJovem perfil) {
    return _banco.collection('jovens').doc(perfil.id).set({
      'nome': perfil.nome,
      'email': perfil.email,
      'cidade': perfil.cidade,
      'dataNascimento': Timestamp.fromDate(perfil.dataNascimento),
      'autorizacaoResponsavel': perfil.autorizacaoResponsavel,
      'aceitePoliticaEm': Timestamp.fromDate(perfil.aceitePoliticaEm),
      'criadoEm': FieldValue.serverTimestamp(),
    });
  }
}
