import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'data/firebase_autenticacao.dart';
import 'data/firestore_perfis.dart';
import 'firebase_options.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    NexoFutureApp(
      autenticacao: FirebaseAutenticacao(),
      perfis: FirestorePerfis(),
    ),
  );
}
