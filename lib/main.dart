import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'views/game/game_screen.dart';
import 'views/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CHIRIBITO',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: AuthWrapper(), 
    );
  }
}


class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Escucha los cambios de estado de autenticación (Login/Logout)
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Mostrar pantalla de carga si no hay datos
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Login correcto.
        if (snapshot.hasData) {
          return const GameScreen(); 
        }
        else {
          // El usuario no ha iniciado sesión.
          return const LoginScreen();
        }
      },
    );
  }
}