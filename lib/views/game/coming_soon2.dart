import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PokerComingSoonScreen2 extends StatelessWidget {
  const PokerComingSoonScreen2({super.key});

  static const Color _darkGreenBg = Color(0xFF0A2F1F);
  static const Color _darkerBg = Color(0xFF051A12);
  static const Color _goldAccent = Color(0xFFFFD700);
  static const Color _goldMuted = Color(0xFFCFA948);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. FONDO
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

          // 2. CONTENIDO PRINCIPAL
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 20.0,
              ),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- LOGO ---
                    Image.asset('assets/images/logo.png', height: 250),

                    const SizedBox(height: 30),
                    // --- TÍTULO ---
                    Text(
                      "PRÓXIMAMENTE",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cinzelDecorative(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _goldAccent,
                        letterSpacing: 2.0,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withValues(alpha: 0.5),
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    // --- SUBTÍTULO ---
                    Text(
                      "La mesa definitiva se está preparando.\n¿Estás listo para ir All-In?",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // --- ANIMACIÓN LOTTIE ---
                    SizedBox(
                      height: 200,
                      child: Lottie.asset(
                        'assets/lottie/chip.json',
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 50),
                    // --- REDES SOCIALES ---
                    Text(
                      "SÍGUENOS EN",
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _goldMuted,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(
                          icon: FontAwesomeIcons.facebook,
                          url: "https://www.facebook.com/share/1H7ciFU2mT/",
                        ),
                        const SizedBox(width: 25),
                        _buildSocialButton(
                          icon: FontAwesomeIcons.instagram,
                          url: "https://www.instagram.com/chiribito293",
                        ),
                        const SizedBox(width: 25),
                        _buildSocialButton(
                          icon: FontAwesomeIcons.tiktok,
                          url: "https://www.tiktok.com/@chiribito.com",
                        ),
                        const SizedBox(width: 25),
                        _buildSocialButton(
                          icon: FontAwesomeIcons.youtube,
                          url: "https://www.youtube.com/@Chiribito293",
                        ),
                        const SizedBox(width: 25),
                        _buildSocialButton(
                          icon: FontAwesomeIcons.xTwitter,
                          url: "https://x.com/Chiribito293",
                        ),
                        const SizedBox(width: 25),
                        _buildSocialButton(
                          icon: FontAwesomeIcons.linkedin,
                          url:
                              "https://www.linkedin.com/company/chiribito-com/",
                        ),
                        const SizedBox(width: 25),
                        _buildSocialButton(
                          icon: FontAwesomeIcons.threads,
                          url: "https://www.threads.com/@chiribito293",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper para los botones sociales redondos
  Widget _buildSocialButton({required IconData icon, required String url}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _goldMuted.withValues(alpha: 0.3), width: 1),
        color: Colors.black.withValues(alpha: 0.3),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: () async{ 
            final Uri uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.platformDefault);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: FaIcon(icon, color: _goldAccent, size: 24),
          ),
        ),
      ),
    );
  }
}
