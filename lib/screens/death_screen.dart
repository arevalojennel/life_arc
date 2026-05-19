import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../main.dart';
import '../services/game_state.dart';
import '../widgets/stat_bar.dart';
import 'splash_screen.dart';

String _money(int v) {
  if (v >= 1000000) return '\$${(v / 1000000).toStringAsFixed(1)}M';
  if (v >= 1000) return '\$${(v / 1000).toStringAsFixed(1)}k';
  return '\$$v';
}

class DeathScreen extends StatelessWidget {
  const DeathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<GameState>();
    final ch = state.character!;
    final birthYear = DateTime.now().year - ch.age;
    final deathYear = DateTime.now().year;

    return Scaffold(
      body: Container(
        // Dark navy gradient exactly from mockup
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F1520), Color(0xFF141C28), Color(0xFF1A2535)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              children: [
                // Leaf icon
                const Icon(Icons.eco, color: Color(0xFF6BAF8A), size: 26)
                    .animate()
                    .fadeIn(duration: 700.ms),

                const SizedBox(height: 16),

                // "Life Complete" serif
                Text('Life Complete',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: C.deathText))
                    .animate()
                    .fadeIn(delay: 200.ms),

                const SizedBox(height: 6),

                Text('You lived to age ${ch.age}',
                        style:
                            GoogleFonts.inter(fontSize: 13, color: C.deathSub))
                    .animate()
                    .fadeIn(delay: 280.ms),

                const SizedBox(height: 28),

                // Grayscale circular avatar
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF2A2D36),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.12), width: 2),
                  ),
                  child: ClipOval(
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        0.33,
                        0.33,
                        0.33,
                        0,
                        0,
                        0.33,
                        0.33,
                        0.33,
                        0,
                        0,
                        0.33,
                        0.33,
                        0.33,
                        0,
                        0,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ]),
                      child: CustomPaint(
                        painter: _AgingFacePainter(),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 350.ms),

                const SizedBox(height: 18),

                // Name
                Text(ch.name,
                        style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: C.deathText))
                    .animate()
                    .fadeIn(delay: 420.ms),

                const SizedBox(height: 4),

                // Years "1942 – 2024"
                Text('$birthYear – $deathYear',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color: C.deathSub,
                            letterSpacing: 0.5))
                    .animate()
                    .fadeIn(delay: 480.ms),

                const SizedBox(height: 16),

                // Legacy paragraph
                Text(
                  'You lived a full life filled with adventure, '
                  'meaningful connections, and personal growth. '
                  '${ch.name} leaves behind a legacy that will be remembered.',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: C.deathSub, height: 1.7),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 540.ms),

                const SizedBox(height: 28),

                // Stat bars
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: C.deathCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.07)),
                  ),
                  child: Column(children: [
                    StatBarCompact(
                        label: 'Health', value: ch.health, color: C.health),
                    StatBarCompact(
                        label: 'Happiness',
                        value: ch.happiness,
                        color: C.happy),
                    StatBarCompact(
                        label: 'Wealth', value: ch.wealth, color: C.wealth),
                    StatBarCompact(
                        label: 'Relationships',
                        value: ch.relationships,
                        color: C.social),
                  ]),
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 24),

                // Life events
                if (ch.lifeEvents.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: C.deathCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.07)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your Story',
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: C.deathSub,
                                letterSpacing: 0.8)),
                        const SizedBox(height: 12),
                        ...AnimateList(
                          interval: 50.ms,
                          effects: [FadeEffect(delay: 750.ms)],
                          children: ch.lifeEvents
                              .map((e) => Padding(
                                    padding: const EdgeInsets.only(bottom: 9),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(top: 6),
                                          width: 4,
                                          height: 4,
                                          decoration: BoxDecoration(
                                              color:
                                                  C.deathSub.withOpacity(0.4),
                                              shape: BoxShape.circle),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(e,
                                              style: GoogleFonts.inter(
                                                  color: C.deathSub,
                                                  fontSize: 12,
                                                  height: 1.6)),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 680.ms),
                  const SizedBox(height: 24),
                ],

                // "View Full Summary" outlined button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: C.deathText,
                      side: BorderSide(
                          color: Colors.white.withOpacity(0.18), width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('View Full Summary',
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: C.deathText)),
                  ),
                ).animate().fadeIn(delay: 800.ms),

                const SizedBox(height: 14),

                // "New Life ↺" text link
                GestureDetector(
                  onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const SplashScreen())),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('New Life',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              color: C.deathSub,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(width: 4),
                      const Icon(Icons.refresh, size: 15, color: C.deathSub),
                    ],
                  ),
                ).animate().fadeIn(delay: 860.ms),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AgingFacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    // Face
    canvas.drawCircle(
        Offset(cx, cy + 4), 30, Paint()..color = const Color(0xFFBB9977));
    // White hair
    final hair = Paint()..color = const Color(0xFFDDDDDD);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy + 4), radius: 30),
        3.14, 3.14, false, hair);
    // Beard
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy + 24), width: 28, height: 14),
        hair);
    // Eyes (tired)
    final eye = Paint()..color = const Color(0xFF442200);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx - 9, cy + 4), width: 8, height: 5),
        eye);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx + 9, cy + 4), width: 8, height: 5),
        eye);
  }

  @override
  bool shouldRepaint(_) => false;
}
