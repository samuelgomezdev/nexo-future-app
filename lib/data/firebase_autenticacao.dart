import 'package:firebase_auth/firebase_auth.dart';

import '../domain/autenticacao.dart';
import '../domain/erros.dart';

/// Liga o login do app ao Firebase Auth (e-mail e senha).
class FirebaseAutenticacao implements ServicoAutenticacao {
  FirebaseAutenticacao([FirebaseAuth? auth])
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  // Códigos que o Firebase devolve para e-mail ou senha que não conferem.
  static const _codigosCredenciais = {
    'invalid-credential',
    'wrong-password',
    'user-not-found',
    'invalid-email',
  };

  @override
  Future<Usuario> entrar(String email, String senha) async {
    try {
      final resultado = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      final usuario = resultado.user!;
      return Usuario(
        id: usuario.uid,
        email: usuario.email ?? email,
        emailVerificado: usuario.emailVerified,
      );
    } on FirebaseAuthException catch (e) {
      if (_codigosCredenciais.contains(e.code)) {
        throw const CredenciaisInvalidas();
      }
      rethrow;
    }
  }

  @override
  Future<Usuario> criarConta(String email, String senha) async {
    try {
      final resultado = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      final usuario = resultado.user!;
      return Usuario(
        id: usuario.uid,
        email: usuario.email ?? email,
        emailVerificado: usuario.emailVerified,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') throw const EmailJaCadastrado();
      rethrow;
    }
  }

  @override
  Future<void> sair() => _auth.signOut();

  @override
  Future<void> enviarConfirmacaoEmail() async {
    await _auth.setLanguageCode('pt');
    await _auth.currentUser?.sendEmailVerification();
  }
}
