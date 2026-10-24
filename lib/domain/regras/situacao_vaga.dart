import '../erros.dart';
import '../models/vaga.dart';

/// RF0007: a vaga só aceita candidatura na situação aguardando ingresso.
void garantirVagaDisponivel(Vaga vaga) {
  if (vaga.situacao != SituacaoVaga.aguardandoIngresso) {
    throw const VagaNaoDisponivel();
  }
}
