import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream para monitorar alterações no estado de autenticação em tempo real
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuário atualmente autenticado
  User? get currentUser => _auth.currentUser;

  // Realizar cadastro com e-mail e senha
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Ocorreu um erro inesperado ao criar a conta. Tente novamente.';
    }
  }

  // Realizar login com e-mail e senha
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Ocorreu um erro inesperado ao fazer login. Tente novamente.';
    }
  }

  // Fazer logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Tradução amigável de erros do Firebase Auth
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Nenhum treinador encontrado com este e-mail.';
      case 'wrong-password':
        return 'Senha incorreta. Tente novamente.';
      case 'invalid-credential':
        return 'E-mail ou senha inválidos.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado em outra conta.';
      case 'invalid-email':
        return 'O formato do e-mail informado é inválido.';
      case 'weak-password':
        return 'A senha é muito fraca. Digite pelo menos 6 caracteres.';
      case 'user-disabled':
        return 'Esta conta de usuário foi desativada.';
      case 'too-many-requests':
        return 'Muitas tentativas consecutivas. Tente novamente mais tarde.';
      case 'network-request-failed':
        return 'Sem conexão com a internet. Verifique sua rede.';
      default:
        return e.message ?? 'Falha na autenticação. Verifique os dados e tente novamente.';
    }
  }
}
