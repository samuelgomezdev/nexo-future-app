import '../erros.dart';
import '../models/vaga.dart';

/// RF0007: a vaga só aceita candidatura na situação aguardando ingresso.
void garantirVagaDisponivel(Vaga vaga) {
  if (vaga.situacao != SituacaoVaga.aguardandoIngresso) {
    throw const VagaNaoDisponivel();
  }
}

/// Conta a candidatura na vaga; a que completa as posições deixa a vaga lotada.
Vaga registrarCandidatura(Vaga vaga) {
  garantirVagaDisponivel(vaga);
  final total = vaga.candidaturas + 1;
  return vaga.copiar(
    candidaturas: total,
    situacao: total >= vaga.posicoes
        ? SituacaoVaga.lotada
        : SituacaoVaga.aguardandoIngresso,
  );
}

/// Desconta a candidatura de quem desistiu; a vaga lotada volta a aceitar.
Vaga liberarCandidatura(Vaga vaga) {
  final total = vaga.candidaturas > 0 ? vaga.candidaturas - 1 : 0;
  return vaga.copiar(
    candidaturas: total,
    situacao: vaga.situacao == SituacaoVaga.lotada && total < vaga.posicoes
        ? SituacaoVaga.aguardandoIngresso
        : vaga.situacao,
  );
}
