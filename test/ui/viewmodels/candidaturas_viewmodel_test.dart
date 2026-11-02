import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/data/candidatura_repository.dart';
import 'package:nexo_future_app/data/vaga_repository.dart';
import 'package:nexo_future_app/domain/models/vaga.dart';
import 'package:nexo_future_app/domain/autenticacao.dart';
import 'package:nexo_future_app/domain/models/jovem.dart';
import 'package:nexo_future_app/ui/viewmodels/candidaturas_viewmodel.dart';
import 'package:nexo_future_app/ui/viewmodels/sessao_viewmodel.dart';

import '../../apoio/autenticacao_falsa.dart';
import '../../apoio/candidaturas_falsas.dart';

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

    Future<void> candidatarNasCinco() async {
      for (var i = 0; i < 5; i++) {
        await viewModel.candidatar(vagas[i]);
      }
    }

    test('candidatura numa vaga disponível é enviada', () async {
      final resultado = await viewModel.candidatar(vagas[0]);

      expect(resultado, ResultadoCandidatura.enviada);
      expect(viewModel.jaCandidatou(vagas[0]), isTrue);
      expect(viewModel.vagasCandidatadas, [vagas[0]]);
      expect(avisos, 1);
    });

    test('a 6ª candidatura devolve limite atingido (RN0005)', () async {
      await candidatarNasCinco();

      expect(
        await viewModel.candidatar(vagas[5]),
        ResultadoCandidatura.limiteAtingido,
      );
      expect(viewModel.limiteAtingido, isTrue);
      expect(viewModel.vagasCandidatadas, hasLength(5));
    });

    test('vaga que não aguarda ingresso devolve vaga indisponível', () async {
      expect(
        await viewModel.candidatar(vagas[6]),
        ResultadoCandidatura.vagaIndisponivel,
      );
      expect(viewModel.vagasCandidatadas, isEmpty);
    });

    test(
      'candidatar-se de novo na mesma vaga devolve já candidatado',
      () async {
        await viewModel.candidatar(vagas[0]);

        expect(
          await viewModel.candidatar(vagas[0]),
          ResultadoCandidatura.jaCandidatado,
        );
      },
    );

    test('desistir libera uma vaga do limite (RF0017)', () async {
      await candidatarNasCinco();

      await viewModel.desistir(vagas[2]);

      expect(viewModel.limiteAtingido, isFalse);
      expect(viewModel.vagasCandidatadas, isNot(contains(vagas[2])));
      expect(
        await viewModel.candidatar(vagas[5]),
        ResultadoCandidatura.enviada,
      );
    });

    test('mostra quantas candidaturas ativas o aluno tem', () async {
      await viewModel.candidatar(vagas[0]);
      await viewModel.candidatar(vagas[1]);

      expect(viewModel.totalAtivas, 2);
      expect(viewModel.limite, 5);
    });
  });

  group('CandidaturasViewModel segue a conta de quem entrou', () {
    final vagas = [for (var i = 1; i <= 3; i++) vaga(i)];
    late CandidaturasFalsas guardadas;
    late SessaoViewModel sessao;
    late CandidaturasViewModel viewModel;

    PerfilJovem jovem(String id) => PerfilJovem(
      id: id,
      nome: 'Carla Lima',
      email: 'carla.lima@example.com',
      cidade: 'Navegantes',
      dataNascimento: DateTime(2004, 3, 2),
      autorizacaoResponsavel: false,
      aceitePoliticaEm: DateTime(2026, 11, 1),
    );

    Usuario usuario(String id) =>
        Usuario(id: id, email: '$id@example.com', emailVerificado: true);

    setUp(() {
      guardadas = CandidaturasFalsas();
      sessao = SessaoViewModel(AutenticacaoFalsa());
      viewModel = CandidaturasViewModel(
        CandidaturaRepository(alunoId: 'jovem-demo', fonte: guardadas),
        VagaRepository(vagas),
        sessao: sessao,
      );
    });

    Future<void> entrar(String id) async {
      sessao.entrou(jovem(id), usuario: usuario(id));
      await pumpEventQueue();
    }

    test('ao entrar, carrega as candidaturas salvas do jovem', () async {
      await guardadas.salvar('uid-carla', ['vaga-2']);

      await entrar('uid-carla');

      expect(viewModel.vagasCandidatadas, [vagas[1]]);
    });

    test('a candidatura fica salva na conta do jovem', () async {
      await entrar('uid-carla');

      await viewModel.candidatar(vagas[0]);

      expect(await guardadas.carregar('uid-carla'), ['vaga-1']);
    });

    test('ao sair, as candidaturas somem do aparelho', () async {
      await entrar('uid-carla');
      await viewModel.candidatar(vagas[0]);

      await sessao.sair();

      expect(viewModel.vagasCandidatadas, isEmpty);
      expect(viewModel.totalAtivas, 0);
    });

    test('sem internet, avisa e não conta a candidatura', () async {
      await entrar('uid-carla');
      guardadas.falhaInesperada = Exception('sem internet');

      expect(
        await viewModel.candidatar(vagas[0]),
        ResultadoCandidatura.falhaConexao,
      );
      expect(viewModel.jaCandidatou(vagas[0]), isFalse);
    });

    test('sem internet, a desistência não acontece', () async {
      await entrar('uid-carla');
      await viewModel.candidatar(vagas[0]);
      guardadas.falhaInesperada = Exception('sem internet');

      expect(await viewModel.desistir(vagas[0]), isFalse);
      expect(viewModel.jaCandidatou(vagas[0]), isTrue);
    });

    test('candidatura feita enquanto as salvas carregam não apaga as '
        'anteriores', () async {
      await guardadas.salvar('uid-carla', ['vaga-2']);
      final lento = guardadas.carregamentoLento = Completer<void>();
      sessao.entrou(jovem('uid-carla'), usuario: usuario('uid-carla'));

      final resultado = viewModel.candidatar(vagas[0]);
      lento.complete();

      expect(await resultado, ResultadoCandidatura.enviada);
      expect(await guardadas.carregar('uid-carla'), ['vaga-2', 'vaga-1']);
    });

    test('se as salvas não carregaram, não grava por cima delas', () async {
      await guardadas.salvar('uid-carla', ['vaga-2']);
      guardadas.falhaAoCarregar = Exception('sem internet');
      await entrar('uid-carla');

      expect(
        await viewModel.candidatar(vagas[0]),
        ResultadoCandidatura.falhaConexao,
      );
      guardadas.falhaAoCarregar = null;
      expect(await guardadas.carregar('uid-carla'), ['vaga-2']);
    });
  });
}
