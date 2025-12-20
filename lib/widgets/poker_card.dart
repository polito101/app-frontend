import 'package:flutter/material.dart';

class PokerCard extends StatelessWidget {
  final String? rank; // 'A', 'K', '10'...
  final String? suit; // 'H', 'D', 'C', 'S'
  final bool isFaceUp;
  final double width;

  const PokerCard({
    super.key,
    this.rank,
    this.suit,
    this.isFaceUp = true,
    this.width = 50,
  });

  @override
  Widget build(BuildContext context) {
    // Proporción estándar de carta de poker (2.5 x 3.5 inches aprox)
    final height = width * 1.4;

    if (!isFaceUp) {
      // Reverso de la carta
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.blue[900],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(2, 2))],
        ),
        child: Center(
          child: Container(
            width: width * 0.8,
            height: height * 0.8,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue[400]!, width: 1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      );
    }

    // Color del palo
    Color suitColor = (suit == 'H' || suit == 'D') ? Colors.red : Colors.black;
    String suitSymbol = _getSuitSymbol(suit!);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(2, 2))],
      ),
      child: Stack(
        children: [
          // Número esquina superior
          Positioned(
            top: 2,
            left: 2,
            child: Column(
              children: [
                Text(rank!, style: TextStyle(color: suitColor, fontWeight: FontWeight.bold, fontSize: width * 0.35)),
                Text(suitSymbol, style: TextStyle(color: suitColor, fontSize: width * 0.25)),
              ],
            ),
          ),
          // Símbolo grande en el centro
          Center(
            child: Text(suitSymbol, style: TextStyle(color: suitColor, fontSize: width * 0.5)),
          ),
        ],
      ),
    );
  }

  String _getSuitSymbol(String suit) {
    switch (suit) {
      case 'H': return '♥';
      case 'D': return '♦';
      case 'C': return '♣';
      case 'S': return '♠';
      default: return '?';
    }
  }
}

class PlayerSeat extends StatelessWidget {
  final String name;
  final String chips;
  final bool isActive; // Si es su turno
  final bool isMe;     // Para resaltar al usuario

  const PlayerSeat({
    super.key,
    required this.name,
    required this.chips,
    this.isActive = false,
    this.isMe = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.yellow : (isMe ? Colors.greenAccent : Colors.black38),
            boxShadow: [BoxShadow(blurRadius: 8, color: isActive ? Colors.yellow.withOpacity(0.6) : Colors.transparent)],
          ),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[800],
            child: Icon(Icons.person, color: Colors.white70),
          ),
        ),
        const SizedBox(height: 4),
        // Placa de info
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: Column(
            children: [
              Text(name, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              Text("\$$chips", style: const TextStyle(color: Colors.greenAccent, fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }
}