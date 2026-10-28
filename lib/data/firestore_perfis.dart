import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/models/empresa.dart';
import '../domain/models/jovem.dart';
import '../domain/models/oficina.dart';

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

  @override
  Future<void> salvarEmpresa(PerfilEmpresa perfil) {
    return _banco.collection('empresas').doc(perfil.id).set({
      'nome': perfil.nome,
      'cnpj': perfil.cnpj,
      'setor': perfil.setor,
      'recrutador': perfil.recrutador,
      'email': perfil.email,
      'cidade': perfil.cidade,
      'aceitePoliticaEm': Timestamp.fromDate(perfil.aceitePoliticaEm),
      'criadoEm': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> salvarOficina(PerfilOficina perfil) {
    final alvara = perfil.alvara;
    return _banco.collection('oficinas').doc(perfil.id).set({
      'nome': perfil.nome,
      'cnpj': perfil.cnpj,
      'gestor': perfil.gestor,
      'email': perfil.email,
      'cidade': perfil.cidade,
      if (alvara != null) 'alvaraNumero': alvara.numero,
      if (alvara != null) 'alvaraValidade': Timestamp.fromDate(alvara.validade),
      'aceitePoliticaEm': Timestamp.fromDate(perfil.aceitePoliticaEm),
      'criadoEm': FieldValue.serverTimestamp(),
    });
  }
}
