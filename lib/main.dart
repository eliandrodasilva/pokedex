import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_navigation.dart';
import 'services/auth_service.dart';
import 'utils/app_colors.dart';
import 'widgets/loading_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Aviso de inicialização do Firebase: $e');
  }

  runApp(const PokedexApp());
}

class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokédex',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryRed,
          primary: AppColors.primaryRed,
          surface: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: null, // Usa a fonte padrão do sistema com boa legibilidade
      ),
      home: const AuthWrapper(),
    );
  }
}

/// O AuthWrapper observa as mudanças de autenticação (login/logout) em tempo real.
/// Se houver um usuário autenticado, direciona para o MainNavigationScreen.
/// Caso contrário, apresenta a tela de LoginScreen.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // Enquanto o Firebase restaura o estado da sessão local
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: LoadingWidget(message: 'Restaurando sessão do treinador...'),
          );
        }

        // Se o usuário já está autenticado
        if (snapshot.hasData && snapshot.data != null) {
          return const MainNavigationScreen();
        }

        // Se não há usuário autenticado
        return const LoginScreen();
      },
    );
  }
}
