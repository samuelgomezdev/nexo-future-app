import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/candidatura_repository.dart';
import '../data/seed_vagas.dart';
import '../data/vaga_repository.dart';
import '../domain/autenticacao.dart';
import '../domain/models/jovem.dart';
import '../domain/regras/cadastro_empresa.dart';
import '../domain/regras/cadastro_jovem.dart';
import '../domain/regras/cadastro_oficina.dart';
import 'screens/lista_vagas_screen.dart';
import 'screens/login_screen.dart';
import 'tema.dart';
import 'viewmodels/cadastro_empresa_viewmodel.dart';
import 'viewmodels/cadastro_jovem_viewmodel.dart';
import 'viewmodels/cadastro_oficina_viewmodel.dart';
import 'viewmodels/candidaturas_viewmodel.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/vagas_viewmodel.dart';

/// Perfil fixo de demonstração da Etapa 1 (sem login).
const alunoDemoId = 'jovem-demo';
const alunoDemoNome = 'Jovem Demo';

class NexoFutureApp extends StatelessWidget {
  const NexoFutureApp({super.key, this.autenticacao, this.perfis});

  /// Com o serviço de autenticação, o app abre no login;
  /// sem ele, abre direto nas vagas, como na demonstração da Etapa 1.
  final ServicoAutenticacao? autenticacao;

  /// Com os perfis, o login oferece os cadastros de jovem, empresa e oficina.
  final RepositorioPerfis? perfis;

  @override
  Widget build(BuildContext context) {
    final vagas = VagaRepository(seedVagas);
    final autenticacao = this.autenticacao;
    final perfis = this.perfis;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VagasViewModel(vagas)),
        ChangeNotifierProvider(
          create: (_) => CandidaturasViewModel(
            CandidaturaRepository(alunoId: alunoDemoId),
            vagas,
          ),
        ),
        if (autenticacao != null)
          ChangeNotifierProvider(
            create: (_) => LoginViewModel(EntrarNaConta(autenticacao)),
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
        home: autenticacao != null
            ? LoginScreen(permiteCadastro: perfis != null)
            : const ListaVagasScreen(),
      ),
    );
  }
}
