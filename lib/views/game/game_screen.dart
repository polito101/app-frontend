import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/socket_service.dart';
import '../../widgets/poker_card.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameSocketService _socketService = GameSocketService();
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  // Estado del Juego
  List<dynamic> _myCards = [];
  List<dynamic> _publicPlayers = [];
  String _roomId = '';
  int _potSize = 0;
  
  // Lógica de Turnos
  int _currentTurnIndex = -1; // Quién debe jugar ahora
  int _mySeatIndex = -1;      // En qué silla estoy yo
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupSocketListeners();
    _socketService.connectAndAuthenticate();
  }

  void _setupSocketListeners() {
    // 1. Fase Lobby
    _socketService.listeners?.onRoomEvents(
      onJoined: (data) {
        if (mounted) {
          setState(() {
            _roomId = data['roomId'];
            _publicPlayers = data['players'] ?? [];
            _potSize = int.tryParse(data['pot'].toString()) ?? 0;
            
            // ✅ CORRECCIÓN 1: Leer el turno al unirse
            _currentTurnIndex = data['turn'] ?? 0; 
            
            _isLoading = false;
            _findMySeat();
          });
        }
      },
      onNewPlayer: (data) {
        if (data['players'] != null && mounted) {
          setState(() => _publicPlayers = data['players']);
        }
      },
    );

    // 2. Fase Juego
    _socketService.listeners?.onGameUpdates(
      onUpdate: (data) {
        if (mounted) {
          setState(() {
            _potSize = int.tryParse(data['pot'].toString()) ?? 0;
            _currentTurnIndex = data['turn']; // Actualizar turno
            if (data['players'] != null) {
              _publicPlayers = data['players'];
            }
          });
        }
      },
      onCardsReceived: (cards) {
        if (mounted) setState(() => _myCards = cards);
      },
      onGameStarted: (data) {
        print("🃏 La partida ha comenzado");
        if (mounted) {
           setState(() {
             // ✅ CORRECCIÓN 2: Actualizar turno al empezar
             if (data['turn'] != null) _currentTurnIndex = data['turn'];
             if (data['players'] != null) _publicPlayers = data['players'];
           });
        }
      }
    );
  }

  void _findMySeat() {
    // Busca en la lista de jugadores cuál tiene mi UID
    try {
      final me = _publicPlayers.firstWhere(
        (p) => p['uid'] == _currentUserId,
        orElse: () => null
      );
      if (me != null) {
        setState(() => _mySeatIndex = me['seat']);
        print("💺 Estoy sentado en el asiento: $_mySeatIndex");
      }
    } catch (e) {
      print("Error buscando asiento: $e");
    }
  }

  // --- UI BUILDERS ---

  @override
  Widget build(BuildContext context) {
    // Determinar si es mi turno para habilitar botones
    bool isMyTurn = (_currentTurnIndex != -1 && _currentTurnIndex == _mySeatIndex);

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a), // Fondo oscuro elegante
      appBar: AppBar(
        title: Text(_roomId.isEmpty ? 'Chiribito Poker' : 'Mesa: ${_roomId.substring(0, 8)}...'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.red),
            onPressed: () {
              _socketService.handleLogout();
              Navigator.of(context).pop();
            },
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ---------------------------------------------
            // PARTE SUPERIOR: LA MESA (Opponents + Board)
            // ---------------------------------------------
            Expanded(
              flex: 3,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. El Tapete
                  Container(
                    width: MediaQuery.of(context).size.width * 0.95,
                    height: MediaQuery.of(context).size.height * 0.45,
                    decoration: BoxDecoration(
                      color: const Color(0xFF35654d), // Verde Casino
                      borderRadius: BorderRadius.circular(150),
                      border: Border.all(color: const Color(0xFF4a2c2a), width: 10), // Borde madera
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
                    ),
                    child: const Center(
                      child: Opacity(
                        opacity: 0.15,
                        child: Text("CHIRIBITO", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black)),
                      ),
                    ),
                  ),

                  // 2. Cartas Comunitarias (Board) - Placeholder por ahora
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 35, height: 50,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white10)
                      ),
                    )),
                  ),

                  // 3. El Bote (Pot)
                  Positioned(
                    top: 140, // Ajustar visualmente
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                      child: Text("Bote: \$$_potSize", style: const TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  // 4. Oponentes (Visualización simple)
                  // Filtramos para no mostrarnos a nosotros mismos en la mesa de enfrente
                  ..._buildOpponents(),

                  // 5. Botón de Unirse (Si no hay sala)
                  if (_roomId.isEmpty && !_isLoading)
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() => _isLoading = true);
                        _socketService.actions?.joinGame();
                      },
                      icon: const Icon(Icons.login),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                      label: const Text("BUSCAR PARTIDA", style: TextStyle(fontSize: 18)),
                    ),
                    
                  if (_isLoading)
                    const CircularProgressIndicator(color: Colors.white),
                ],
              ),
            ),

            // ---------------------------------------------
            // PARTE INFERIOR: MI PANEL (Hand + Controls)
            // ---------------------------------------------
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                  boxShadow: [BoxShadow(color: Colors.black, blurRadius: 10, offset: Offset(0, -5))]
                ),
                child: Column(
                  children: [
                    // Info de mi jugador
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(backgroundColor: Colors.blueAccent, radius: 15, child: Icon(Icons.person, size: 18)),
                            const SizedBox(width: 8),
                            Text("TÚ (Hero)", style: TextStyle(color: isMyTurn ? Colors.yellow : Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        // Buscamos mis fichas en la lista pública
                        Text(
                          "Fichas: \$${_getMyChips()}", 
                          style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold)
                        ),
                      ],
                    ),
                    
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(4),
                      color: Colors.red.withOpacity(0.2),
                      child: Text(
                        "DEBUG: Mi Asiento: $_mySeatIndex | Turno de: $_currentTurnIndex | ¿Es mi turno?: ${_mySeatIndex == _currentTurnIndex}",
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),

                    // MIS CARTAS
                    if (_myCards.isNotEmpty)
                      SizedBox(
                        height: 110,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _myCards.map((card) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: PokerCard(
                              rank: card['rank'],
                              suit: card['suit'],
                              width: 75,
                            ),
                          )).toList(),
                        ),
                      )
                    else if (_roomId.isNotEmpty)
                      const Text("Esperando siguiente mano...", style: TextStyle(color: Colors.white38)),

                    const Spacer(),

                    // BOTONERA DE ACCIÓN
                    if (_roomId.isNotEmpty)
                      _myCards.isEmpty 
                      ? SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _socketService.actions?.startGame(),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                            child: const Text("REPARTIR (DEALER)"),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _actionButton("FOLD", Colors.red, "fold", isMyTurn),
                            _actionButton("CHECK", Colors.grey, "check", isMyTurn),
                            _actionButton("BET 100", Colors.orange, "bet", isMyTurn, amount: 100),
                          ],
                        )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPERS ---

  String _getMyChips() {
    if (_mySeatIndex == -1) return "0";
    try {
      final me = _publicPlayers.firstWhere((p) => p['seat'] == _mySeatIndex, orElse: () => null);
      return me != null ? me['chips'].toString() : "0";
    } catch (_) { return "0"; }
  }

  List<Widget> _buildOpponents() {
    if (_publicPlayers.isEmpty) return [];

    // Filtramos para que YO no aparezca en la mesa (ya estoy abajo)
    final opponents = _publicPlayers.where((p) => p['uid'] != _currentUserId).toList();

    // Posiciones fijas simples para 3 oponentes (Arriba, Izq, Der)
    // Para hacerlo perfecto circular se requiere trigonometría, esto es un apaño visual rápido
    List<Widget> widgets = [];
    
    if (opponents.isNotEmpty) widgets.add(Positioned(top: 20, child: _opponentSeat(opponents[0])));
    if (opponents.length > 1) widgets.add(Positioned(left: 10, top: 80, child: _opponentSeat(opponents[1])));
    if (opponents.length > 2) widgets.add(Positioned(right: 10, top: 80, child: _opponentSeat(opponents[2])));
    if (opponents.length > 3) widgets.add(Positioned(bottom: 20, right: 60, child: _opponentSeat(opponents[3])));

    return widgets;
  }

  Widget _opponentSeat(dynamic player) {
    bool isTurn = player['seat'] == _currentTurnIndex;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isTurn ? Colors.yellow : Colors.black38,
            boxShadow: [if (isTurn) BoxShadow(color: Colors.yellow.withOpacity(0.8), blurRadius: 10)]
          ),
          child: const CircleAvatar(radius: 18, backgroundColor: Colors.brown, child: Icon(Icons.person, size: 20)),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          color: Colors.black54,
          child: Text(
            "${player['chips']}\$", 
            style: const TextStyle(color: Colors.white, fontSize: 10)
          ),
        )
      ],
    );
  }

  Widget _actionButton(String label, Color color, String actionType, bool enabled, {int amount = 0}) {
    return ElevatedButton(
      onPressed: enabled ? () {
        _socketService.actions?.sendAction(actionType, amount: amount);
      } : null, // Deshabilita el botón visualmente si no es el turno
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: color.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }
}