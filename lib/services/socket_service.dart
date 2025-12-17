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
          .setTransports(['polling', 'websocket']) // Importante: deja ambos por ahora
          .setAuth({'token': idToken})             // 👈 ¡NUEVO! Envía el token al conectar
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

    socket!.onConnect((_) {
      print('✅✅ Conectado al servidor de sockets');
      socket!.emit('authenticate', {'token': idToken});
      _isConnected = true;
    });

    // 👇 AÑADE ESTO PARA VER EL ERROR REAL
    socket!.on('connect_error', (data) {
      print('❌❌ ERROR DE CONEXIÓN: $data');
    });
    
    socket!.on('connect_timeout', (data) {
      print('⏰⏰ TIMEOUT DE CONEXIÓN: $data');
    });
  }

  // --- MÉTODOS DE JUEGO (EMITTERS) ---

  // NUEVO: Para buscar mesa
  void joinGame() {
    // Imprimimos el estado actual para depurar
    print('Intento de unirse. Socket: ${socket != null}, Conectado: $_isConnected');

    if (socket != null && _isConnected) {
      print('🔍 Enviando evento join_game al servidor...');
      socket!.emit('join_game');
    } else {
      print('⚠️ ERROR: No se puede buscar partida porque no hay conexión.');
      print(' Estado del socket: ${socket?.connected}');
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