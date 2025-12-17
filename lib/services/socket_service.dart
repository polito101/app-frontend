// lib/services/socket_service.dart

// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:firebase_auth/firebase_auth.dart';

class GameSocketService {
  static final GameSocketService _instance = GameSocketService._internal();
  factory GameSocketService() => _instance;
  GameSocketService._internal();

  IO.Socket? socket; 
  final String serverUrl = 'https://api.chiribito.com';
  bool _isConnected = false;

  // Callback para la UI
  Function(List<dynamic>)? onCardsReceived;

  void connectAndAuthenticate() async {
    if (_isConnected) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final idToken = await user.getIdToken();

    socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket!.onConnect((_) {
      print('✅✅Conectado al servidor de sockets');
      socket!.emit('authenticate', {'token': idToken});
      _isConnected = true;
    });

    socket!.on('authenticated', (data) {
      print('✅✅Autenticado con éxito: $data');
    });

    socket!.onDisconnect((_) {
      _isConnected = false;
      print('⚠️⚠️Desconectado del servidor');
    });

    socket!.connect();
  }

  // --- MÉTODOS DE JUEGO (EMITTERS) ---

  // NUEVO: Para buscar mesa
  void joinGame() {
    if (socket != null && _isConnected) {
      print('🔍 Buscando mesa...');
      socket!.emit('join_game'); // Importante: que coincida con el backend
    }
  }

  void startGame() {
    if (socket != null && _isConnected) {
      print('🃏 Solicitando iniciar partida...');
      socket!.emit('start_game');
    }
  }

  // --- ESCUCHADORES (LISTENERS) ---

  void listenToGameEvents(Function(Map<String, dynamic>) onRoomJoined) {
    if (socket == null) return;

    // Escuchar cuando nos unimos a una sala
    socket!.on('joined_room', (data) {
      print('🚀 Sala unida: ${data['roomId']}');
      onRoomJoined(data);
    });

    // Escuchar cartas privadas
    socket!.on('your_cards', (data) {
      print('🃏 Cartas recibidas: ${data['cards']}');
      if (onCardsReceived != null) {
        onCardsReceived!(data['cards']);
      }
    });
    
    // Escuchar aviso global
    socket!.on('game_started', (data) {
      print('🔔 El juego ha comenzado oficialmente');
    });

    // Manejo de errores del servidor
    socket!.on('error', (data) {
      print('❌ Error del servidor: ${data['message']}');
    });
  }

  Future<void> handleLogout() async {
    if (socket != null) { 
      socket!.disconnect();
    }
    await FirebaseAuth.instance.signOut();
    _isConnected = false;
  }
}