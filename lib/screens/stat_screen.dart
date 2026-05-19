import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../models/character.dart';

// Standalone stats screen — also used as tab body inside HistoryScreen
class StatsBody extends StatelessWidget {
  final Character character;
  const StatsBody({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    final stats = [
      _S(
        'Health',
        character.healthHistory.isNotEmpty
            ? character.healthHistory.last
            : character.health,
        C.health,
        C.healthBg,
        Icons.favorite,
        'heartbeat',
        character.healthHistory,
      ),
      _S(
        'Happiness',
        character.happiness,
        C.happy,
        C.happyBg,
        Icons.sentiment_satisfied_alt,
        'mood',
        character.happinessHistory,
      ),
      _S(
        'Wealth',
        character.wealth,
        C.wealth,
        C.wealthBg,
        Icons.savings,
        'savings',
        character.wealthHistory,
      ),
      _S(
        'Relationships',
        character.relationships,
        C.social,
        C.socialBg,
        Icons.people,
        'social',
        character.relationshipHistory,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        ...stats.map((s) => _StatSection(stat: s)),
        const SizedBox(height: 16),
        // Footer note from mockup
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, size: 13, color: C.inkFaint),
              const SizedBox(width: 6),
              Text(
                  'Your stats are influenced by\nyour choices and life events.',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: C.inkFaint, height: 1.5),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatSection extends StatelessWidget {
  final _S stat;
  const _StatSection({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: icon + label + value
          Row(children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: stat.bg, shape: BoxShape.circle),
              child: Icon(stat.icon, color: stat.color, size: 17),
            ),
            const SizedBox(width: 10),
            Text(stat.label,
                style: GoogleFonts.inter(
                    fontSize: 15, fontWeight: FontWeight.w600, color: C.ink)),
            const Spacer(),
            Text('${stat.value} / 100',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    color: C.inkSub,
                    fontWeight: FontWeight.w500)),
          ]),
          const SizedBox(height: 10),

          // Sparkline chart (simulated with paint)
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: C.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: C.div),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CustomPaint(
                painter: _SparklinePainter(
                  history: stat.history,
                  color: stat.color,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _S {
  final String label;
  final int value;
  final Color color;
  final Color bg;
  final IconData icon;
  final String key;
  final List<int> history; // ✅ ADD THIS
  const _S(
    this.label,
    this.value,
    this.color,
    this.bg,
    this.icon,
    this.key,
    this.history,
  );
}

class _SparklinePainter extends CustomPainter {
  final List<int> history;
  final Color color;

  _SparklinePainter({
    required this.history,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;

    const padding = 8.0;

    final usableWidth = size.width - (padding * 2);
    final usableHeight = size.height - (padding * 2);

    final paintLine = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Single point fallback
    if (history.length < 2) {
      final normalized = history.first.clamp(0, 100) / 100;
      final y = padding + (usableHeight - (normalized * usableHeight));

      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        paintLine,
      );

      return;
    }

    final path = Path();

    final stepX = usableWidth / (history.length - 1);

    for (int i = 0; i < history.length; i++) {
      final normalized = history[i].clamp(0, 100) / 100;

      final x = padding + (i * stepX);

      final y = padding + (usableHeight - (normalized * usableHeight));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.history != history || oldDelegate.color != color;
  }
}
