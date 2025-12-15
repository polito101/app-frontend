import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:firebase_auth/firebase_auth.dart';

class GameSocketService {
  late IO.Socket socket;
  final String serverUrl = 'https://api.chiribito.com';

  void connectAndAuthenticate() async {
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
      print('⚠️⚠️Desconectado del servidor de sockets');
    });

    socket.connect();

    void disconnect() {
      socket.disconnect();
    }
  }
}
