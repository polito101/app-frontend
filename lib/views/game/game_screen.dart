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
      appBar: AppBar(
        title: Text('Game Screen'),
      ),
      body: Center(
        child: Text('Welcome to the Game!'),
      ),
    );
  }
}