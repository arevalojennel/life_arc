import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import 'character_creation_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Warm gradient background matching mockup
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF2EBE0),
                  Color(0xFFE8DDD0),
                  Color(0xFFD4C8B8),
                  Color(0xFFC2B8A8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Winding path illustration
          Positioned.fill(
            child: CustomPaint(painter: _ScenePainter()),
          ),

          SafeArea(
            child: Stack(
              children: [
                // Gear icon top-right
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Icon(Icons.settings_outlined,
                        color: C.ink.withOpacity(0.45), size: 22),
                  ),
                ),

                Column(
                  children: [
                    const SizedBox(height: 56),

                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Life",
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 54,
                              fontWeight: FontWeight.w700,
                              color: C.ink,
                              letterSpacing: -0.5,
                            ),
                          ),
                          TextSpan(
                            text: "Arc",
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 54,
                              fontWeight: FontWeight.normal,
                              color: C.ink,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Live a thousand lives.\nEvery choice shapes yours.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: C.inkSub,
                        height: 1.65,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const Spacer(),

                    // Buttons at bottom
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 0, 28, 44),
                      child: Column(
                        children: [
                          // New Life — dark filled pill
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const CharacterCreationScreen()),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: C.dark,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999)),
                              ),
                              child: Text('New Life',
                                  style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),

                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Golden arc halo behind title area
    final arcPaint = Paint()
      ..color = const Color(0xFFC8A870).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.14),
        width: 200,
        height: 100,
      ),
      3.14,
      3.14,
      false,
      arcPaint,
    );

    // Winding path
    final pathPaint = Paint()
      ..color = const Color(0xFF9A8870).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.85);
    path.cubicTo(
      size.width * 0.45,
      size.height * 0.75,
      size.width * 0.58,
      size.height * 0.65,
      size.width * 0.52,
      size.height * 0.55,
    );
    path.cubicTo(
      size.width * 0.46,
      size.height * 0.46,
      size.width * 0.54,
      size.height * 0.38,
      size.width * 0.5,
      size.height * 0.30,
    );
    canvas.drawPath(path, pathPaint);

    // Hills / landscape silhouettes
    final hillPaint = Paint()
      ..color = const Color(0xFF8A7A65).withOpacity(0.18)
      ..style = PaintingStyle.fill;

    final hills = Path();
    hills.moveTo(0, size.height * 0.88);
    hills.quadraticBezierTo(size.width * 0.25, size.height * 0.72,
        size.width * 0.5, size.height * 0.82);
    hills.quadraticBezierTo(
        size.width * 0.75, size.height * 0.92, size.width, size.height * 0.80);
    hills.lineTo(size.width, size.height);
    hills.lineTo(0, size.height);
    hills.close();
    canvas.drawPath(hills, hillPaint);

    // Silhouette figure
    final figPaint = Paint()
      ..color = const Color(0xFF3A3028).withOpacity(0.5)
      ..style = PaintingStyle.fill;
    final cx = size.width * 0.5;
    final cy = size.height * 0.79;
    // Head
    canvas.drawCircle(Offset(cx, cy - 14), 6, figPaint);
    // Body
    final body = Path()
      ..moveTo(cx - 4, cy - 8)
      ..lineTo(cx + 4, cy - 8)
      ..lineTo(cx + 5, cy + 8)
      ..lineTo(cx - 5, cy + 8)
      ..close();
    canvas.drawPath(body, figPaint);
    // Legs
    canvas.drawRect(Rect.fromLTWH(cx - 5, cy + 6, 4, 10), figPaint);
    canvas.drawRect(Rect.fromLTWH(cx + 1, cy + 6, 4, 10), figPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}
