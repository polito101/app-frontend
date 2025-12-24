import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:firebase_auth/firebase_auth.dart';
import 'game_listeners.dart';
import 'game_actions.dart'; // 👈 Importamos el nuevo archivo

class GameSocketService {
  static final GameSocketService _instance = GameSocketService._internal();
  factory GameSocketService() => _instance;
  
  IO.Socket? socket;
  final String serverUrl = 'https://api.chiribito.com'; 
  bool _isConnected = false;

  GameListeners? _listeners;
  GameActions? _actions;

  GameSocketService._internal() {
    _initSocket();
  }

  void _initSocket() {
    socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );
    
    // Inicializamos ambas partes
    if (socket != null) {
      _listeners = GameListeners(socket!);
      _actions = GameActions(socket!);
    }
  }

  // Getters seguros
  GameListeners? get listeners => _listeners;
  GameActions? get actions => _actions;

  void connectAndAuthenticate() async {
    if (_isConnected || socket == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final idToken = await user.getIdToken();

    socket!.io.options?['auth'] = {'token': idToken};
    
    socket!.onConnect((_) {
      print('✅✅ Conectado al servidor');
      _isConnected = true;
    });
    
    socket!.onDisconnect((_) => _isConnected = false);
    socket!.connect();
  }

  Future<void> handleLogout() async {
    socket?.disconnect();
    await FirebaseAuth.instance.signOut();
  }
}