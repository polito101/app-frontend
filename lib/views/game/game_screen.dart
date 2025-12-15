import 'package:flutter/material.dart';
import '../../services/socket_service.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameSocketService _socketService = GameSocketService();

  @override
  void initState() {
    super.initState();
    _socketService.connectAndAuthenticate();
  }

  @override
  void dispose() {
    _socketService.socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Game Screen')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Welcome to the Game!'),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('CERRAR SESIÓN'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              print('👋👋Cerrando sesión y desconectando socket...');
              GameSocketService().handleLogout();
              print(' llegado hasta aqui 2');
            },
          ),
        ],
      ),
    );
  }
}
