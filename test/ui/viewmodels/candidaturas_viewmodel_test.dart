import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/data/candidatura_repository.dart';
import 'package:nexo_future_app/data/vaga_repository.dart';
import 'package:nexo_future_app/domain/models/vaga.dart';
import 'package:nexo_future_app/ui/viewmodels/candidaturas_viewmodel.dart';

Vaga vaga(
  int numero, {
  SituacaoVaga situacao = SituacaoVaga.aguardandoIngresso,
}) => Vaga(
  id: 'vaga-$numero',
  titulo: 'Vaga $numero',
  empresa: 'TransVale Logística',
  area: 'Logística',
  cidade: 'Navegantes',
  qualificacao: 'Ensino médio completo',
  situacao: situacao,
);

void main() {
  group('CandidaturasViewModel (F3 e F4: candidatar-se e desistir)', () {
    final vagas = [
      for (var i = 1; i <= 6; i++) vaga(i),
      vaga(7, situacao: SituacaoVaga.aberta),
    ];
    late CandidaturasViewModel viewModel;
    late int avisos;

    setUp(() {
      viewModel = CandidaturasViewModel(
        CandidaturaRepository(alunoId: 'jovem-demo'),
        VagaRepository(vagas),
      );
      avisos = 0;
      viewModel.addListener(() => avisos++);
    });

    void candidatarNasCinco() {
      for (var i = 0; i < 5; i++) {
        viewModel.candidatar(vagas[i]);
      }
    }

    test('candidatura numa vaga disponível é enviada', () {
      final resultado = viewModel.candidatar(vagas[0]);

      expect(resultado, ResultadoCandidatura.enviada);
      expect(viewModel.jaCandidatou(vagas[0]), isTrue);
      expect(viewModel.vagasCandidatadas, [vagas[0]]);
      expect(avisos, 1);
    });

    test('a 6ª candidatura devolve limite atingido (RN0005)', () {
      candidatarNasCinco();

      expect(
        viewModel.candidatar(vagas[5]),
        ResultadoCandidatura.limiteAtingido,
      );
      expect(viewModel.limiteAtingido, isTrue);
      expect(viewModel.vagasCandidatadas, hasLength(5));
    });

    test('vaga que não aguarda ingresso devolve vaga indisponível', () {
      expect(
        viewModel.candidatar(vagas[6]),
        ResultadoCandidatura.vagaIndisponivel,
      );
      expect(viewModel.vagasCandidatadas, isEmpty);
    });

    test('candidatar-se de novo na mesma vaga devolve já candidatado', () {
      viewModel.candidatar(vagas[0]);

      expect(
        viewModel.candidatar(vagas[0]),
        ResultadoCandidatura.jaCandidatado,
      );
    });

    test('desistir libera uma vaga do limite (RF0017)', () {
      candidatarNasCinco();

      viewModel.desistir(vagas[2]);

      expect(viewModel.limiteAtingido, isFalse);
      expect(viewModel.vagasCandidatadas, isNot(contains(vagas[2])));
      expect(viewModel.candidatar(vagas[5]), ResultadoCandidatura.enviada);
    });

    test('mostra quantas candidaturas ativas o aluno tem', () {
      viewModel.candidatar(vagas[0]);
      viewModel.candidatar(vagas[1]);

      expect(viewModel.totalAtivas, 2);
      expect(viewModel.limite, 5);
    });
  });
}
