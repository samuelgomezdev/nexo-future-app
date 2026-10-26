import '../erros.dart';

/// RNF0007: 5 senhas erradas seguidas bloqueiam o login por 15 minutos.
const maximoTentativasLogin = 5;
const tempoBloqueioLogin = Duration(minutes: 15);

class ControleTentativasLogin {
  ControleTentativasLogin({DateTime Function()? relogio})
    : _relogio = relogio ?? DateTime.now;

  final DateTime Function() _relogio;
  int _falhas = 0;
  DateTime? _bloqueadoAte;

  bool get bloqueado => tempoRestante > Duration.zero;

  Duration get tempoRestante {
    final ate = _bloqueadoAte;
    if (ate == null) return Duration.zero;
    final restante = ate.difference(_relogio());
    if (restante > Duration.zero) return restante;
    // O bloqueio acabou: devolve as tentativas.
    _bloqueadoAte = null;
    _falhas = 0;
    return Duration.zero;
  }

  int get tentativasRestantes =>
      bloqueado ? 0 : maximoTentativasLogin - _falhas;

  void garantirLiberado() {
    final restante = tempoRestante;
    if (restante > Duration.zero) throw LoginBloqueado(restante);
  }

  void registrarFalha() {
    if (bloqueado) return;
    _falhas++;
    if (_falhas >= maximoTentativasLogin) {
      _bloqueadoAte = _relogio().add(tempoBloqueioLogin);
    }
  }

  void registrarSucesso() {
    _falhas = 0;
    _bloqueadoAte = null;
  }
}
