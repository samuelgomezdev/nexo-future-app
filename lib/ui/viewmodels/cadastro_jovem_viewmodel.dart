import '../../domain/models/jovem.dart';
import '../../domain/regras/cadastro_jovem.dart';
import 'cadastro_viewmodel.dart';

final _formatoDataBr = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$');

/// Lê uma data digitada como dd/mm/aaaa; devolve null se não existir.
DateTime? lerDataBr(String texto) {
  final partes = _formatoDataBr.firstMatch(texto.trim());
  if (partes == null) return null;
  final dia = int.parse(partes[1]!);
  final mes = int.parse(partes[2]!);
  final data = DateTime(int.parse(partes[3]!), mes, dia);
  // DateTime aceita 31/02 e vira 03/03: confere se a data é a mesma.
  if (data.day != dia || data.month != mes) return null;
  return data;
}

/// C2 do protótipo: cadastro do jovem.
class CadastroJovemViewModel
    extends CadastroViewModel<DadosCadastroJovem, PerfilJovem> {
  CadastroJovemViewModel(
    CadastrarJovem cadastrar, {
    DateTime Function()? relogio,
  }) : _relogio = relogio ?? DateTime.now,
       super(cadastrar.call);

  final DateTime Function() _relogio;

  bool precisaAutorizacao(DateTime? nascimento) {
    if (nascimento == null) return false;
    final idade = idadeEm(nascimento, _relogio());
    return idade >= idadeMinima && idade < maioridade;
  }
}
