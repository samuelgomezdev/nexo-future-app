import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/domain/autenticacao.dart';
import 'package:nexo_future_app/domain/models/cadastro.dart';
import 'package:nexo_future_app/domain/models/curso.dart';
import 'package:nexo_future_app/domain/models/empresa.dart';
import 'package:nexo_future_app/domain/models/oficina.dart';
import 'package:nexo_future_app/domain/regras/aprovacao_curso.dart';
import 'package:nexo_future_app/domain/regras/cadastro_curso.dart';
import 'package:nexo_future_app/domain/regras/cadastro_vaga.dart';
import 'package:nexo_future_app/ui/viewmodels/novo_curso_viewmodel.dart';
import 'package:nexo_future_app/ui/viewmodels/nova_vaga_viewmodel.dart';
import 'package:nexo_future_app/ui/viewmodels/paineis_viewmodel.dart';

import '../../apoio/vagas_falsas.dart';

void main() {
  final hoje = DateTime(2026, 11, 10);

  final empresa = PerfilEmpresa(
    id: 'uid-marcos',
    nome: 'Estaleiro Foz Azul',
    cnpj: '11222333000181',
    setor: 'Naval',
    recrutador: 'Marcos Pereira',
    email: 'rh@fozazul.example.com',
    cidade: 'Itajaí',
    aceitePoliticaEm: DateTime(2026, 11, 1),
  );
  const marcos = Usuario(
    id: 'uid-marcos',
    email: 'rh@fozazul.example.com',
    emailVerificado: true,
  );

  PerfilOficina oficina({Alvara? alvara}) => PerfilOficina(
    id: 'uid-rita',
    nome: 'Oficina Escola Mãos do Porto',
    cnpj: '11222333000181',
    gestor: 'Rita Moraes',
    email: 'contato@maosdoporto.example.com',
    cidade: 'Itajaí',
    alvara: alvara,
    aceitePoliticaEm: DateTime(2026, 11, 1),
  );
  final comAlvara = oficina(
    alvara: Alvara(numero: 'AE-2026-0042', validade: DateTime(2027, 3, 1)),
  );
  const rita = Usuario(
    id: 'uid-rita',
    email: 'contato@maosdoporto.example.com',
    emailVerificado: true,
  );

  const vagaAberta = Vaga(
    id: 'vaga-pintor',
    titulo: 'Pintor(a) naval',
    empresa: 'Estaleiro Foz Azul',
    area: 'Naval',
    cidade: 'Itajaí',
    qualificacao: 'Pintura de cascos.',
    situacao: SituacaoVaga.aberta,
    empresaId: 'uid-marcos',
    posicoes: 3,
  );

  const dadosVaga = DadosVaga(
    titulo: 'Soldador(a)',
    area: 'Metalurgia',
    posicoes: 2,
    cidade: 'Navegantes',
    qualificacao: 'Solda MIG/MAG.',
  );

  DadosCurso dadosCurso({String nome = 'Pintura naval'}) => DadosCurso(
    nome: nome,
    vaga: vagaAberta,
    cargaHoraria: 32,
    vagasTurma: 15,
    descricao: '',
  );

  late VagasFalsas vagas;

  setUp(() => vagas = VagasFalsas([vagaAberta]));

  group('NovaVagaViewModel (tela E2)', () {
    late NovaVagaViewModel viewModel;

    setUp(() => viewModel = NovaVagaViewModel(PublicarVaga(vagas)));

    test('publica a vaga e guarda o resultado', () async {
      final estados = <bool>[];
      viewModel.addListener(() => estados.add(viewModel.carregando));

      final publicou = await viewModel.publicar(
        usuario: marcos,
        empresa: empresa,
        dados: dadosVaga,
      );

      expect(publicou, isTrue);
      expect(viewModel.vaga?.titulo, 'Soldador(a)');
      expect(viewModel.vaga?.situacao, SituacaoVaga.aberta);
      expect(estados, [true, false]);
      expect(vagas.vagas, hasLength(2));
    });

    test('aponta os campos obrigatórios vazios', () async {
      final publicou = await viewModel.publicar(
        usuario: marcos,
        empresa: empresa,
        dados: const DadosVaga(
          titulo: '',
          area: '',
          posicoes: null,
          cidade: '',
          qualificacao: '',
        ),
      );

      expect(publicou, isFalse);
      expect(viewModel.erros.keys, {
        CampoCadastro.titulo,
        CampoCadastro.area,
        CampoCadastro.posicoes,
        CampoCadastro.cidade,
        CampoCadastro.qualificacao,
      });
    });

    test('corrigir um campo tira o erro dele', () async {
      await viewModel.publicar(
        usuario: marcos,
        empresa: empresa,
        dados: const DadosVaga(
          titulo: '',
          area: 'Naval',
          posicoes: 1,
          cidade: 'Itajaí',
          qualificacao: 'x',
        ),
      );

      viewModel.limparErro(CampoCadastro.titulo);

      expect(viewModel.erros, isEmpty);
    });

    test('com e-mail não confirmado, explica o motivo (RN0001)', () async {
      final publicou = await viewModel.publicar(
        usuario: const Usuario(
          id: 'uid-marcos',
          email: 'rh@fozazul.example.com',
          emailVerificado: false,
        ),
        empresa: empresa,
        dados: dadosVaga,
      );

      expect(publicou, isFalse);
      expect(
        viewModel.erroGeral,
        'Confirme seu e-mail pelo link que enviamos antes de entrar.',
      );
    });

    test('sem internet, pede para tentar de novo', () async {
      vagas.falhaInesperada = Exception('sem internet');

      final publicou = await viewModel.publicar(
        usuario: marcos,
        empresa: empresa,
        dados: dadosVaga,
      );

      expect(publicou, isFalse);
      expect(
        viewModel.erroGeral,
        'Não foi possível salvar agora. Confira sua internet e tente de novo.',
      );
      expect(viewModel.carregando, isFalse);
    });
  });

  group('NovoCursoViewModel (tela O2)', () {
    late NovoCursoViewModel viewModel;

    setUp(() {
      viewModel = NovoCursoViewModel(
        PublicarCurso(vagas, relogio: () => hoje),
        vagas,
      );
    });

    test('lista só as vagas que ainda recebem cursos', () async {
      vagas.vagas['lotada'] = vagaAberta.copiar(situacao: SituacaoVaga.lotada);
      vagas.vagas['seed'] = const Vaga(
        id: 'seed',
        titulo: 'Laminador',
        empresa: 'Estaleiro Foz Azul',
        area: 'Naval',
        cidade: 'Itajaí',
        qualificacao: 'Ensino fundamental completo',
        situacao: SituacaoVaga.aberta,
      );

      await viewModel.carregarVagas();

      expect(viewModel.vagasDisponiveis.map((v) => v.id), ['vaga-pintor']);
    });

    test('com alvará, publica o curso para a análise do recrutador', () async {
      final publicou = await viewModel.publicar(
        usuario: rita,
        oficina: comAlvara,
        dados: dadosCurso(),
      );

      expect(publicou, isTrue);
      expect(viewModel.curso?.situacao, SituacaoCurso.emAnalise);
    });

    test('sem alvará, explica o motivo e não publica (RN0003)', () async {
      final publicou = await viewModel.publicar(
        usuario: rita,
        oficina: oficina(),
        dados: dadosCurso(),
      );

      expect(publicou, isFalse);
      expect(
        viewModel.erroGeral,
        'Envie o alvará de ensino da oficina para publicar cursos.',
      );
      expect(vagas.cursos, isEmpty);
    });

    test('sem alvará, salva o rascunho', () async {
      final salvou = await viewModel.publicar(
        usuario: rita,
        oficina: oficina(),
        dados: dadosCurso(),
        rascunho: true,
      );

      expect(salvou, isTrue);
      expect(viewModel.curso?.situacao, SituacaoCurso.rascunho);
    });

    test('aponta os campos a corrigir', () async {
      await viewModel.publicar(
        usuario: rita,
        oficina: comAlvara,
        dados: dadosCurso(nome: ''),
      );

      expect(viewModel.erros.keys, [CampoCadastro.nome]);
    });
  });

  group('PainelEmpresaViewModel (telas E1 e E3)', () {
    late PainelEmpresaViewModel viewModel;

    CursoOficina proposto(String id) => CursoOficina(
      id: id,
      nome: 'Curso $id',
      area: 'Naval',
      cargaHoraria: 32,
      vagasTurma: 15,
      descricao: '',
      vagaId: 'vaga-pintor',
      vagaTitulo: 'Pintor(a) naval',
      empresaId: 'uid-marcos',
      empresa: 'Estaleiro Foz Azul',
      oficinaId: 'uid-rita',
      oficina: 'Oficina Escola Mãos do Porto',
      situacao: SituacaoCurso.emAnalise,
    );

    setUp(() {
      viewModel = PainelEmpresaViewModel(vagas, DecidirCurso(vagas));
      vagas.cursos['c1'] = proposto('c1');
      vagas.cursos['c2'] = proposto('c2');
    });

    test('carrega as vagas da empresa e os cursos para aprovar', () async {
      vagas.vagas['de-outra'] = const Vaga(
        id: 'de-outra',
        titulo: 'Motorista',
        empresa: 'TransVale',
        area: 'Logística',
        cidade: 'Itajaí',
        qualificacao: 'CNH D',
        situacao: SituacaoVaga.aberta,
        empresaId: 'uid-outra',
      );

      await viewModel.carregar('uid-marcos');

      expect(viewModel.vagas.map((v) => v.id), ['vaga-pintor']);
      expect(viewModel.paraAprovar, hasLength(2));
      expect(viewModel.cursosDaVaga('vaga-pintor'), hasLength(2));
      expect(viewModel.vagasAbertas, 1);
      expect(viewModel.totalCandidaturas, 0);
    });

    test('soma as candidaturas recebidas nas vagas da empresa', () async {
      vagas.vagas['vaga-pintor'] = vagaAberta.copiar(
        situacao: SituacaoVaga.aguardandoIngresso,
        candidaturas: 2,
      );

      await viewModel.carregar('uid-marcos');

      expect(viewModel.totalCandidaturas, 2);
    });

    test('aprovar vincula o curso e recarrega o painel', () async {
      await viewModel.carregar('uid-marcos');

      final aprovou = await viewModel.aprovar(
        usuario: marcos,
        empresa: empresa,
        curso: vagas.cursos['c1']!,
      );

      expect(aprovou, isTrue);
      expect(viewModel.paraAprovar.map((c) => c.id), ['c2']);
      expect(viewModel.vagas.single.situacao, SituacaoVaga.aguardandoIngresso);
    });

    test('recusar tira o curso da lista', () async {
      await viewModel.carregar('uid-marcos');

      final recusou = await viewModel.recusar(
        usuario: marcos,
        empresa: empresa,
        curso: vagas.cursos['c2']!,
      );

      expect(recusou, isTrue);
      expect(viewModel.paraAprovar.map((c) => c.id), ['c1']);
      expect(viewModel.vagas.single.situacao, SituacaoVaga.aberta);
    });

    test('a vaga com 5 cursos explica por que não aprova o 6º', () async {
      vagas.vagas['vaga-pintor'] = vagaAberta.copiar(
        situacao: SituacaoVaga.aguardandoIngresso,
        cursos: [
          for (var i = 1; i <= 5; i++)
            Curso(id: 'v$i', nome: 'Curso $i', oficina: 'Oficina'),
        ],
      );
      await viewModel.carregar('uid-marcos');

      final aprovou = await viewModel.aprovar(
        usuario: marcos,
        empresa: empresa,
        curso: vagas.cursos['c1']!,
      );

      expect(aprovou, isFalse);
      expect(viewModel.erroGeral, 'Esta vaga já tem 5 cursos vinculados.');
    });

    test('sem internet, avisa ao carregar', () async {
      vagas.falhaInesperada = Exception('sem internet');

      await viewModel.carregar('uid-marcos');

      expect(
        viewModel.erroGeral,
        'Não foi possível carregar agora. Confira sua internet e tente de novo.',
      );
      expect(viewModel.carregando, isFalse);
    });
  });

  group('PainelOficinaViewModel (tela O1)', () {
    late PainelOficinaViewModel viewModel;

    setUp(() {
      viewModel = PainelOficinaViewModel(
        vagas,
        PublicarCurso(vagas, relogio: () => hoje),
      );
    });

    test('carrega os cursos da oficina', () async {
      await PublicarCurso(vagas, relogio: () => hoje)(
        usuario: rita,
        oficina: comAlvara,
        dados: dadosCurso(),
      );

      await viewModel.carregar('uid-rita');

      expect(viewModel.cursos.single.nome, 'Pintura naval');
    });

    test('publica o rascunho quando o alvará está em dia', () async {
      final rascunho = await PublicarCurso(vagas, relogio: () => hoje)(
        usuario: rita,
        oficina: oficina(),
        dados: dadosCurso(),
        rascunho: true,
      );
      await viewModel.carregar('uid-rita');

      final semAlvara = await viewModel.publicarRascunho(
        usuario: rita,
        oficina: oficina(),
        curso: rascunho,
      );
      expect(semAlvara, isFalse);
      expect(
        viewModel.erroGeral,
        'Envie o alvará de ensino da oficina para publicar cursos.',
      );

      final publicou = await viewModel.publicarRascunho(
        usuario: rita,
        oficina: comAlvara,
        curso: rascunho,
      );
      expect(publicou, isTrue);
      expect(viewModel.cursos.single.situacao, SituacaoCurso.emAnalise);
      expect(viewModel.erroGeral, isNull);
    });
  });
}
