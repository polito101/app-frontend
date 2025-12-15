// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:firebase_auth/firebase_auth.dart';

class GameSocketService {
  static final GameSocketService _instance = GameSocketService._internal();
  factory GameSocketService() => _instance;
  GameSocketService._internal();

  late IO.Socket socket;
  final String serverUrl = 'https://api.chiribito.com';
  bool _isConnected = false;

  void connectAndAuthenticate() async {
    if (_isConnected) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('🚫🚫Usuario no autenticado');
      return;
    }
    final idToken = await user.getIdToken();

    socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    //Aqui se manejan eventos
    socket.onConnect((_) {
      _isConnected = true;
      print('✅✅Conectado al servidor de sockets');
      socket.emit('authenticate', {'token': idToken});
    });

    socket.on('authenticated', (data) {
      print('✅✅Autenticado con éxito: $data');
    });

    socket.on('unauthorized', (data) {
      print('🚫🚫Autenticación fallida: $data');
      socket.disconnect();
    });

    socket.onDisconnect((_) {
      _isConnected = false;
      print('⚠️⚠️Desconectado del servidor de sockets');
    });

    socket.connect();

    // ignore: unused_element
    void disconnect() {
      _isConnected = false;
      socket.disconnect();
    }
  }

  // Manejo de Logout
  Future<void> handleLogout() async {
      if (!_isConnected) return;

      socket.disconnect();
      _isConnected = false;
      print('👋👋Usuario desconectado y socket cerrado');

      await FirebaseAuth.instance.signOut();
    }
}
