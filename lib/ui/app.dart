import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/candidatura_repository.dart';
import '../data/seed_vagas.dart';
import '../data/vaga_repository.dart';
import '../domain/autenticacao.dart';
import 'screens/lista_vagas_screen.dart';
import 'screens/login_screen.dart';
import 'tema.dart';
import 'viewmodels/candidaturas_viewmodel.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/vagas_viewmodel.dart';

/// Perfil fixo de demonstração da Etapa 1 (sem login).
const alunoDemoId = 'jovem-demo';
const alunoDemoNome = 'Jovem Demo';

class NexoFutureApp extends StatelessWidget {
  const NexoFutureApp({super.key, this.autenticacao});

  /// Com o serviço de autenticação, o app abre no login;
  /// sem ele, abre direto nas vagas, como na demonstração da Etapa 1.
  final ServicoAutenticacao? autenticacao;

  @override
  Widget build(BuildContext context) {
    final vagas = VagaRepository(seedVagas);
    final autenticacao = this.autenticacao;
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
      ],
      child: MaterialApp(
        title: 'Nexo Future',
        debugShowCheckedModeBanner: false,
        theme: temaNexo(),
        home: autenticacao != null
            ? const LoginScreen()
            : const ListaVagasScreen(),
      ),
    );
  }
}
