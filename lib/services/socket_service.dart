import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:firebase_auth/firebase_auth.dart';

class GameSocketService {
  static final GameSocketService _instance = GameSocketService._internal();
  factory GameSocketService() => _instance;
  
  // 1. Inicializamos el socket en el constructor (sin conectar aún)
  GameSocketService._internal() {
    _initSocket();
  }

  IO.Socket? socket;
  final String serverUrl = 'https://api.chiribito.com'; 
  bool _isConnected = false;
  Function(List<dynamic>)? onCardsReceived;

  //Nueva función interna para preparar el objeto
  void _initSocket() {
    socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect() // Importante: No conecta todavía
          .build(),
    );
  }

  // 3. Modificamos connectAndAuthenticate para usar el socket que YA existe
  void connectAndAuthenticate() async {
    if (_isConnected) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final idToken = await user.getIdToken();

    // Actualizamos la auth del socket existente
    socket!.io.options?['auth'] = {'token': idToken};
    
    socket!.onConnect((_) {
      print('✅✅ Conectado al servidor');
      _isConnected = true;
    });
    
    socket!.onDisconnect((_) => _isConnected = false);

    socket!.connect();
  }

  void listenToGameEvents(Function(Map<String, dynamic>) onRoomJoined) {
    if (socket == null) _initSocket(); 

    socket!.off('joined_room'); 
    
    socket!.on('joined_room', (data) {
      print('🚀 Sala unida: ${data['roomId']}');
      onRoomJoined(data);
    });

    socket!.on('your_cards', (data) {
      if (onCardsReceived != null) onCardsReceived!(data['cards']);
    });
    
    socket!.on('game_started', (_) => print('🔔 Juego iniciado'));
  }

  void joinGame() {
    if (socket != null) {
      print('🔍 Buscando mesa...');
      socket!.emit('join_game');
    }
  }

  void startGame() {
    if (socket != null) socket!.emit('start_game');
  }

  Future<void> handleLogout() async {
    socket?.disconnect();
    await FirebaseAuth.instance.signOut();
  }
}