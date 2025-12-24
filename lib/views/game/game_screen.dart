import 'package:flutter/material.dart';
import '../../services/socket_service.dart';
import '../../widgets/poker_card.dart'; // Asegúrate de importar el archivo que creamos arriba

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameSocketService _socketService = GameSocketService();
  
  // Estado del juego
  List<dynamic> _myCards = [];
  List<dynamic> _publicPlayers = []; 
  String _roomId = '';
  final int _potSize = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // 1. Escuchar mis cartas privadas
    _socketService.onCardsReceived = (cards) {
      if (mounted) setState(() => _myCards = cards);
    };

    // 2. Escuchar eventos generales de la sala
    _socketService.listenToGameEvents((data) {
      if (mounted) {
        setState(() {
          _roomId = data['roomId'];
          // data['players'] viene de playersPublic (uid, seat, chips)
          _publicPlayers = data['players'] ?? [];
          _isLoading = false;
        });
      }
    });

    // 3. Conectar al entrar
    _socketService.connectAndAuthenticate();
  }

  void _handleJoinGame() {
    setState(() => _isLoading = true);
    _socketService.joinGame();
  }

  @override
  Widget build(BuildContext context) {
    // Fondo de madera o textura oscura
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        title: Text(_roomId.isEmpty ? 'Chiribito Poker' : 'Mesa: $_roomId'),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.red),
            onPressed: () {
               _socketService.handleLogout();
               Navigator.of(context).pop(); // O redirigir a Login
            },
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ÁREA DE JUEGO (Mesa)
            Expanded(
              flex: 3,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. La Mesa (El fieltro verde)
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF35654d), // Verde tapete clásico
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: const Color(0xFF4a2c2a), width: 12), // Borde madera
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
                    ),
                    child: Center(
                      // Logo o decoración central
                      child: Opacity(
                        opacity: 0.1,
                        child: Text("CHIRIBITO", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black)),
                      ),
                    ),
                  ),

                  // 2. Las Cartas Comunitarias (Board)
                  // Por ahora vacías, pero aquí irían Flop, Turn, River
                  Positioned(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (index) => Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                          width: 40, height: 56,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white24),
                            borderRadius: BorderRadius.circular(4)
                          ),
                          child: Center(child: Text("?", style: TextStyle(color: Colors.white24))),
                        ),
                      )),
                    ),
                  ),

                  // 3. El Bote (Pot)
                  const Positioned(
                    top: 180, // Ajustar según pantalla
                    child: Chip(
                      label: Text("Bote: \$0", style: TextStyle(fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.black54,
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                  ),

                  // 4. Los Asientos de los Oponentes (Ejemplo estático visual)
                  // Aquí deberías mapear _publicPlayers para posicionarlos.
                  // Pongo ejemplos fijos para que veas el efecto visual:
                  const Positioned(top: 20, child: PlayerSeat(name: "Rival 1", chips: "1500")),
                  const Positioned(top: 60, left: 20, child: PlayerSeat(name: "Rival 2", chips: "800")),
                  const Positioned(top: 60, right: 20, child: PlayerSeat(name: "Rival 3", chips: "2200")),
                  
                  // Mensaje si no hay sala
                  if (_roomId.isEmpty && !_isLoading)
                     Center(child: ElevatedButton(
                       onPressed: _handleJoinGame,
                       style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                       child: Text("BUSCAR PARTIDA", style: TextStyle(fontSize: 18)),
                     )),
                     
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator(color: Colors.white)),
                ],
              ),
            ),

            // ÁREA DE MI JUGADOR (Panel de control)
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    // MIS DATOS
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PlayerSeat(name: "TÚ (Hero)", chips: "1000", isMe: true, isActive: true),
                        Text("Esperando acción...", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    
                    const Spacer(),

                    // MIS CARTAS
                    if (_myCards.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _myCards.map((card) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: PokerCard(
                              rank: card['rank'],
                              suit: card['suit'],
                              width: 70,
                            ),
                          )).toList(),
                        ),
                      )
                    else 
                      const Text("Esperando reparto...", style: TextStyle(color: Colors.white30, fontStyle: FontStyle.italic)),

                    const Spacer(),

                    // BOTONERA DE ACCIÓN
                    if (_myCards.isEmpty && _roomId.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _socketService.startGame(),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: EdgeInsets.symmetric(vertical: 15)),
                          child: const Text("REPARTIR CARTAS (DEALER)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      
                    // Botones de juego (Fold, Call, Raise) - Visuales por ahora
                    if (_myCards.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _actionButton("FOLD", Colors.red),
                          _actionButton("CHECK", Colors.grey),
                          _actionButton("BET", Colors.orange),
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

  Widget _actionButton(String label, Color color) {
    return ElevatedButton(
      onPressed: () {}, // Lógica futura
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}