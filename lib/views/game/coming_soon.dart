import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

class PokerComingSoonScreen extends StatelessWidget {
  const PokerComingSoonScreen({super.key});

  // Definimos una paleta de colores premium para Póker
  static const Color _darkGreenBg = Color(0xFF0A2F1F); // Verde oscuro tapete
  static const Color _darkerBg = Color(0xFF051A12); // Casi negro
  static const Color _goldAccent = Color(0xFFFFD700); // Dorado brillante
  static const Color _goldMuted = Color(0xFFCFA948); // Dorado más serio

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos un Stack para superponer el fondo, elementos decorativos y el contenido principal
      body: Stack(
        children: [
          // 1. CAPA DE FONDO: Degradado radial para dar profundidad
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [_darkGreenBg, _darkerBg],
                center: Alignment.center,
                radius: 1.2,
                stops: [0.3, 1.0],
              ),
            ),
          ),

          /*Opacity(
            opacity: 0.1,
            child: Image.asset(
              'assets/images/tapete.',
              fit: BoxFit.cover,
              height: double.infinity,
            ),
          ),*/

          // 3. CONTENIDO PRINCIPAL
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 20.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- SECCIÓN DEL LOGO ---
                  Image.asset('assets/images/logo.jpeg', height: 120),
                  //_buildPlaceholderLogo(),

                  const SizedBox(height: 50),

                  // --- SECCIÓN DE TEXTO ---
                  Text(
                    "PRÓXIMAMENTE",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cinzelDecorative(
                      // Tipografía estilo clásico/romano
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _goldAccent,
                      letterSpacing: 2.0,
                      shadows: [
                        Shadow(
                          // Sombra sutil para que el texto resalte
                          blurRadius: 10.0,
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "La mesa definitiva se está preparando. ¿Estás listo para ir All-In?",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      // Tipografía secundaria limpia
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- SECCIÓN DE ANIMACIÓN LOTTIE ---
                  // Esta es la clave para que se vea "muy bonito" y dinámico.
                  SizedBox(
                    height: 200,
                    // Usa Lottie.asset si descargaste el JSON.
                    // He usado un enlace de red temporal como ejemplo.
                    child: Lottie.asset(
                      // Ejemplo: Unas fichas de poker cayendo.
                      // Búsca uno que te guste en lottiefiles y usa el .json
                      'assets/lottie/chip.json',
                      fit: BoxFit.contain,
                      // Opciones para que la animación sea sutil si es necesario
                      // options: LottieOptions(enableMergePaths: true),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // --- BOTÓN DE ACCIÓN (Opcional) ---
                  // Un botón dorado para capturar leads o notificar
                  ElevatedButton(
                    onPressed: () {
                      // Acción: Mostrar diálogo de suscripción, etc.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "¡Te avisaremos cuando estemos listos!",
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _goldMuted,
                      foregroundColor: _darkerBg, // Color del texto del botón
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      elevation: 5,
                      shadowColor: _goldAccent.withOpacity(0.4),
                    ),
                    child: Text(
                      "NOTIFICARME",
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget temporal para simular tu logo si aún no lo tienes puesto
  Widget _buildPlaceholderLogo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _goldAccent, width: 3),
        boxShadow: [
          BoxShadow(
            color: _goldAccent.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Text(
        "♠️", // Emoji de pica
        style: TextStyle(fontSize: 80, color: _goldAccent),
      ),
    );
  }
}
