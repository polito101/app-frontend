import 'package:socket_io_client/socket_io_client.dart' as IO;

class GameListeners {
  final IO.Socket socket;

  GameListeners(this.socket);

  // 🏠 LISTENER DE SALA (Lobby)
  // Escucha cuando entras, pero también cuando otros entran o salen mientras esperas
  void onRoomEvents({
    required Function(Map<String, dynamic>) onJoined,
    Function(Map<String, dynamic>)? onNewPlayer,
  }) {
    // Limpiamos para no duplicar
    socket.off('joined_room');
    socket.off('player_joined');

    socket.on('joined_room', (data) {
      print('🚀 Sala unida: ${data['roomId']}');
      onJoined(data);
    });

    socket.on('player_joined', (data) {
      print('👋 Nuevo jugador entró: $data');
      if (onNewPlayer != null) onNewPlayer(data);
    });
  }

  // 🃏 LISTENER DE JUEGO (Partida en curso)
  // Escucha el flujo de la partida: turnos, apuestas, cartas comunitarias
  void onGameUpdates({
    required Function(Map<String, dynamic>) onUpdate,
    Function(List<dynamic>)? onCardsReceived,
    Function(Map<String, dynamic>)? onGameStarted,
  }) {
    socket.off('game_update');
    socket.off('your_cards');
    socket.off('game_started');

    // 1. Actualización general (Turno, Bote, Fichas)
    socket.on('game_update', (data) {
      // print('🔄 Estado del juego: $data'); // Descomentar para debug
      onUpdate(data);
    });

    // 2. Mis Cartas Privadas
    socket.on('your_cards', (data) {
      print('🎴 Cartas recibidas');
      if (onCardsReceived != null) {
        onCardsReceived(data['cards']);
      }
    });

    // 3. Inicio de partida (para animaciones o resetear estados)
    socket.on('game_started', (data) {
      print('🔔 ¡Juego iniciado!');
      if (onGameStarted != null) onGameStarted(data);
    });
  }
}