import 'dart:async';

import 'package:nexo_future_app/data/vagas_em_memoria.dart';
import 'package:nexo_future_app/domain/models/curso.dart';

/// Repositório de vagas e cursos falso: simula o Firestore em memória e,
/// quando pedido, uma falha de conexão.
class VagasFalsas extends VagasEmMemoria {
  VagasFalsas([super.iniciais]);

  /// Simula uma falha do banco (sem internet, servidor fora etc.).
  Exception? falhaInesperada;

  void _conferirFalha() {
    final falha = falhaInesperada;
    if (falha != null) throw falha;
  }

  /// Segura a busca no servidor até ser completada, como uma internet lenta.
  Completer<void>? buscaLenta;

  /// Vagas que ficaram guardadas no aparelho (o cache do Firestore).
  List<Vaga> guardadas = const [];

  @override
  Future<List<Vaga>> listarVagas() async {
    await buscaLenta?.future;
    _conferirFalha();
    return super.listarVagas();
  }

  @override
  Future<List<Vaga>> vagasGuardadas() async => guardadas;

  @override
  Future<List<Vaga>> vagasDaEmpresa(String empresaId) async {
    _conferirFalha();
    return super.vagasDaEmpresa(empresaId);
  }

  @override
  Future<void> salvarVaga(Vaga vaga) async {
    _conferirFalha();
    await super.salvarVaga(vaga);
  }

  @override
  Future<void> salvarCurso(CursoOficina curso) async {
    _conferirFalha();
    await super.salvarCurso(curso);
  }

  @override
  Future<List<CursoOficina>> cursosDaOficina(String oficinaId) async {
    _conferirFalha();
    return super.cursosDaOficina(oficinaId);
  }

  @override
  Future<void> decidirCurso(CursoOficina curso, {Vaga? vaga}) async {
    _conferirFalha();
    await super.decidirCurso(curso, vaga: vaga);
  }
}
