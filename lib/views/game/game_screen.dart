import 'package:flutter/material.dart';
import '../../services/socket_service.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameSocketService _socketService = GameSocketService();
  
  // Variables de estado para la UI
  List<dynamic> _myCards = [];
  String _gameStatus = 'Conectando...';
  String _roomId = '';

  @override
  void initState() {
    super.initState();

    // 1. PRIMERO: Configuramos el "oído" para las cartas ANTES de conectar
    _socketService.onCardsReceived = (cards) {
      if (mounted) {
        setState(() {
          _myCards = cards;
        });
      }
    };

    // 2. SEGUNDO: Escuchamos los eventos generales (unirse a sala, etc.)
    _socketService.listenToGameEvents((data) {
      if (mounted) {
        setState(() {
          _gameStatus = 'En sala: ${data['roomId']}';
          _roomId = data['roomId'];
        });
      }
    });

    // 3. TERCERO: Ahora sí, conectamos
    _socketService.connectAndAuthenticate();
  }

  @override
  void dispose() {
    // Es importante limpiar los listeners para evitar fugas de memoria
    _socketService.onCardsReceived = null;
    if (_socketService.socket != null) {
      _socketService.socket!.disconnect();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_gameStatus, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            
            const SizedBox(height: 20),

            // 🃏 MOSTRAR CARTAS SI EXISTEN
            if (_myCards.isNotEmpty) ...[
              const Text("TUS CARTAS:"),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _myCards.map((c) => Chip(
                  label: Text("${c['rank']}${c['suit']}"),
                  backgroundColor: Colors.white,
                )).toList(),
              ),
            ],

            const SizedBox(height: 30),

            // 🔍 BOTÓN BUSCAR PARTIDA (Solo si no estás en una)
            if (_roomId.isEmpty)
              ElevatedButton(
                onPressed: () => _socketService.joinGame(),
                child: const Text('BUSCAR PARTIDA'),
              ),

            // 🎰 BOTÓN REPARTIR (Solo si estás en sala y no tienes cartas aún)
            if (_roomId.isNotEmpty && _myCards.isEmpty)
              ElevatedButton(
                onPressed: () => _socketService.startGame(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('REPARTIR CARTAS'),
              ),

            const SizedBox(height: 50),

            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('CERRAR SESIÓN'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => _socketService.handleLogout(),
            ),
          ],
        ),
      ),
    );
  }
}