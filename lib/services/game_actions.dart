import 'package:socket_io_client/socket_io_client.dart' as IO;

class GameActions {
  final IO.Socket socket;

  GameActions(this.socket);

  // 🚪 Unirse a una mesa
  void joinGame() {
    print('🔍 Buscando mesa...');
    socket.emit('join_game');
  }

  // 🏁 Empezar la partida (Dealer)
  void startGame() {
    print('🚀 Solicitando inicio de partida...');
    socket.emit('start_game');
  }

  // 🕹️ Acciones de juego (Fold, Call, Bet)
  void sendAction(String action, {int amount = 0}) {
    print('📤 Enviando acción: $action ($amount)');
    socket.emit('player_action', {
      'action': action,
      'amount': amount,
    });
  }
}