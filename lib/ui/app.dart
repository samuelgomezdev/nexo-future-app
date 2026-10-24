import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/candidatura_repository.dart';
import '../data/seed_vagas.dart';
import '../data/vaga_repository.dart';
import 'screens/lista_vagas_screen.dart';
import 'viewmodels/candidaturas_viewmodel.dart';
import 'viewmodels/vagas_viewmodel.dart';

/// Perfil fixo de demonstração da Etapa 1 (sem login).
const alunoDemoId = 'jovem-demo';
const alunoDemoNome = 'Jovem Demo';

class NexoFutureApp extends StatelessWidget {
  const NexoFutureApp({super.key});

  @override
  Widget build(BuildContext context) {
    final vagas = VagaRepository(seedVagas);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VagasViewModel(vagas)),
        ChangeNotifierProvider(
          create: (_) => CandidaturasViewModel(
            CandidaturaRepository(alunoId: alunoDemoId),
            vagas,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Nexo Future',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B6E99)),
        ),
        home: const ListaVagasScreen(),
      ),
    );
  }
}
