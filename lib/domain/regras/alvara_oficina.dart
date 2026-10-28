import '../erros.dart';
import '../models/oficina.dart';

/// RN0003: a oficina só publica cursos com o alvará de ensino em dia.
void conferirAlvara(Oficina oficina, {required DateTime hoje}) {
  final alvara = oficina.alvara;
  if (alvara == null || alvara.numero.trim().isEmpty) {
    throw const OficinaSemAlvara();
  }
  final dia = DateTime(hoje.year, hoje.month, hoje.day);
  if (alvara.validade.isBefore(dia)) {
    throw const AlvaraVencido();
  }
}

bool podePublicarCurso(Oficina oficina, {required DateTime hoje}) {
  try {
    conferirAlvara(oficina, hoje: hoje);
    return true;
  } on OficinaSemAlvara {
    return false;
  } on AlvaraVencido {
    return false;
  }
}
