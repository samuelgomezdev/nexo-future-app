import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/candidatura_repository.dart';
import '../data/candidaturas_em_memoria.dart';
import '../data/seed_vagas.dart';
import '../data/vaga_repository.dart';
import '../data/vagas_em_memoria.dart';
import '../domain/autenticacao.dart';
import '../domain/models/candidatura.dart';
import '../domain/models/curso.dart';
import '../domain/models/jovem.dart';
import '../domain/regras/cadastro_empresa.dart';
import '../domain/regras/cadastro_jovem.dart';
import '../domain/regras/cadastro_oficina.dart';
import 'screens/lista_vagas_screen.dart';
import 'tema.dart';
import 'viewmodels/cadastro_empresa_viewmodel.dart';
import 'viewmodels/cadastro_jovem_viewmodel.dart';
import 'viewmodels/cadastro_oficina_viewmodel.dart';
import 'viewmodels/candidaturas_viewmodel.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/sessao_viewmodel.dart';
import 'viewmodels/vagas_viewmodel.dart';

/// Perfil fixo de demonstração da Etapa 1 (sem login).
const alunoDemoId = 'jovem-demo';
const alunoDemoNome = 'Jovem Demo';

class NexoFutureApp extends StatelessWidget {
  const NexoFutureApp({
    super.key,
    this.autenticacao,
    this.perfis,
    this.vagas,
    this.candidaturas,
  });

  /// Com o serviço de autenticação, o visitante vê vagas e cursos e entra para
  /// agir; sem ele, tudo fica liberado, como na demonstração da Etapa 1.
  final ServicoAutenticacao? autenticacao;

  /// Com os perfis, o login oferece os cadastros de jovem, empresa e oficina.
  final RepositorioPerfis? perfis;

  /// Vagas e cursos publicados (o Firestore no app); sem ele, ficam só no
  /// aparelho. Na pesquisa, entram na frente das vagas fictícias do seed.
  final RepositorioVagas? vagas;

  /// Candidaturas de cada jovem (o Firestore no app); sem ele, ficam só no
  /// aparelho.
  final RepositorioCandidaturas? candidaturas;

  @override
  Widget build(BuildContext context) {
    final publicadas = this.vagas ?? VagasEmMemoria();
    final vagas = VagaRepository(seedVagas, fonte: publicadas);
    final candidaturas =
        this.candidaturas ??
        CandidaturasEmMemoria(publicadas is VagasEmMemoria ? publicadas : null);
    final autenticacao = this.autenticacao;
    final perfis = this.perfis;
    return MultiProvider(
      providers: [
        Provider<RepositorioVagas>.value(value: publicadas),
        ChangeNotifierProvider(
          create: (_) => SessaoViewModel(autenticacao, perfis != null),
        ),
        ChangeNotifierProvider(create: (_) => VagasViewModel(vagas)),
        ChangeNotifierProvider(
          create: (contexto) => CandidaturasViewModel(
            CandidaturaRepository(alunoId: alunoDemoId, fonte: candidaturas),
            vagas,
            sessao: contexto.read<SessaoViewModel>(),
          ),
        ),
        if (autenticacao != null)
          ChangeNotifierProvider(
            create: (_) =>
                LoginViewModel(EntrarNaConta(autenticacao), perfis: perfis),
          ),
        if (autenticacao != null && perfis != null) ...[
          ChangeNotifierProvider(
            create: (_) =>
                CadastroJovemViewModel(CadastrarJovem(autenticacao, perfis)),
          ),
          ChangeNotifierProvider(
            create: (_) => CadastroEmpresaViewModel(
              CadastrarEmpresa(autenticacao, perfis),
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => CadastroOficinaViewModel(
              CadastrarOficina(autenticacao, perfis),
            ),
          ),
        ],
      ],
      child: MaterialApp(
        title: 'Nexo Future',
        debugShowCheckedModeBanner: false,
        theme: temaNexo(),
        home: const ListaVagasScreen(),
      ),
    );
  }
}
