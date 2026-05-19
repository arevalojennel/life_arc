import 'package:flutter/material.dart';
import 'package:flutter_modern_animated_loader/flutter_animated_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lifearc/models/character.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../main.dart';
import '../services/game_state.dart';
import '../widgets/networth_container.dart';
import '../widgets/stat_bar.dart';
import 'death_screen.dart';
import 'history_screen.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(builder: (context, state, _) {
      if (state.character == null) {
        return const Scaffold(
            body: Center(
                child:
                    CircularProgressIndicator(color: C.dark, strokeWidth: 2)));
      }
      if (state.phase == GamePhase.dead) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const DeathScreen()));
        });
        return const Scaffold(body: SizedBox());
      }
      if (state.phase == GamePhase.outcome) {
        return _OutcomeScreen(state: state);
      }
      if (state.phase == GamePhase.dead) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DeathScreen()),
          );
        });
        return const Scaffold(body: SizedBox());
      }

      return _MainScreen(state: state);
    });
  }
}

// ── Main screen: hero age + landscape + stats ─────────────────────────────────
class _MainScreen extends StatelessWidget {
  final GameState state;
  const _MainScreen({required this.state});

  @override
  Widget build(BuildContext context) {
    final ch = state.character!;

    return Scaffold(
      backgroundColor: C.surface,
      body: Stack(
        children: [
          Column(
            children: [
              // ── Hero gradient with Age and landscape ──────────────────────
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.38,
                child: Stack(children: [
                  // Landscape gradient background
                  Container(
                    height: MediaQuery.of(context).size.height / 2,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFE8C8A8),
                          Color(0xFFD4A8C8),
                          Color(0xFF8898B8),
                          Color(0xFF5878A0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Landscape scene painter
                  Positioned.fill(
                      child: CustomPaint(painter: _LandscapePainter())),

                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const HistoryScreen())),
                            child: const Icon(Icons.menu,
                                color: Colors.white, size: 22),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Age centered
                  Center(
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(ch.name,
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.85))),
                          const SizedBox(height: 4),
                          Text('Age ${ch.age}',
                              style: GoogleFonts.inter(
                                fontSize: 44,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -1,
                                shadows: [
                                  Shadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8)
                                ],
                              )),
                          const SizedBox(height: 4),
                          Text(ch.lifeStage,
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.85))),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),

              Expanded(
                  child: Container(
                color: Colors.white,
              ))
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 3,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                height: MediaQuery.of(context).size.height / 1.5,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment:
                      state.phase == GamePhase.idle && !state.isLoading ||
                              (state.currentEvent != null &&
                                  (state.phase == GamePhase.event ||
                                      state.phase == GamePhase.choosing))
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.center,
                  children: [
                    // Loading or event card or Age Up button
                    if (state.isLoading)
                      Center(child: _LoadingCard())
                    else if (state.currentEvent != null &&
                        (state.phase == GamePhase.event ||
                            state.phase == GamePhase.choosing))
                      Center(child: _EventCard(state: state))
                    else if (state.phase == GamePhase.idle && !state.isLoading)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          // 4 stat cards
                          StatCard(
                            label: 'Health',
                            value: ch.health,
                            color: C.health,
                            bgColor: C.healthBg,
                            iconWidget: const Icon(Icons.favorite,
                                color: C.health, size: 17),
                          ),
                          StatCard(
                            label: 'Happiness',
                            value: ch.happiness,
                            color: C.happy,
                            bgColor: C.happyBg,
                            iconWidget: const Icon(
                                Icons.sentiment_satisfied_alt,
                                color: C.happy,
                                size: 17),
                          ),
                          StatCard(
                            label: 'Wealth',
                            value: ch.wealth,
                            color: C.wealth,
                            bgColor: C.wealthBg,
                            iconWidget: _dollarIcon(C.wealth),
                          ),
                          StatCard(
                            label: 'Relationships',
                            value: ch.relationships,
                            color: C.social,
                            bgColor: C.socialBg,
                            iconWidget: const Icon(Icons.people,
                                color: C.social, size: 17),
                          ),
                          Consumer<GameState>(
                            builder: (_, game, __) {
                              return NetWorthContainer(
                                value: game.character?.money ?? 0,
                              );
                            },
                          ),

                          const SizedBox(height: 4),
                          _AgeUpButton(
                            onPressed: () => state.ageUp(),
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

  Widget _dollarIcon(Color color) {
    return Container(
      width: 17,
      height: 17,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text('\$',
            style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
        children: [
          FlutterAnimatedLoader.heartBeat(color: C.inkFaint, size: 50),
          const SizedBox(height: 16),
          Text(
            'Life is unfolding…',
            style: GoogleFonts.inter(
                fontSize: 13, color: C.inkSub, fontStyle: FontStyle.italic),
          ),
        ],
      );
}

class _AgeUpButton extends StatelessWidget {
  final void Function()? onPressed;

  const _AgeUpButton({this.onPressed});
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: C.dark,
              foregroundColor: Colors.white,
              elevation: 0,
              side: const BorderSide(color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text('Age Up',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ),
      ]);
}

// ── Event card — exact mockup layout ─────────────────────────────────────────
class _EventCard extends StatelessWidget {
  final GameState state;
  const _EventCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final event = state.currentEvent!;
    // final ch = state.character!;

    // Dot colors for 3 choices
    const dotColors = [C.health, C.happy, C.social];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 8),

        // Row: hamburger + "Age 25" + bookmark  (matches event screen top)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // const Icon(Icons.menu, color: C.ink, size: 20),
            Text('Life Event',
                style: GoogleFonts.inter(
                    fontSize: 15, fontWeight: FontWeight.w600, color: C.ink)),
            // const Icon(Icons.bookmark_border, color: C.inkFaint, size: 20),
          ],
        ),

        // Underline below age
        const SizedBox(height: 4),
        Center(
          child: Container(
            width: 40,
            height: 2,
            decoration: BoxDecoration(
                color: C.ink, borderRadius: BorderRadius.circular(999)),
          ),
        ),
        const SizedBox(height: 16),

        // "Life Event" small label

        // Bold title
        Text(
          event.title,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: C.ink,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(event.description,
            style:
                GoogleFonts.inter(fontSize: 13, color: C.inkSub, height: 1.6)),
        const SizedBox(height: 16),
        event.isChoiceEvent
            ? Column(
                children: [
                  Text('What will you do?',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: C.inkSub,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),

                  // Choice cards
                  ...event.choices.asMap().entries.map((e) {
                    final color = dotColors[e.key % dotColors.length];
                    return _ChoiceCard(
                      choice: e.value,
                      dotColor: color,
                      onTap: () => state.makeChoice(e.value),
                    );
                  }),
                  const SizedBox(height: 12),
                ],
              )
            : const SizedBox.shrink(),

        // "Stats may change" footer
        Row(children: [
          const Icon(Icons.bar_chart_outlined, size: 13, color: C.inkFaint),
          const SizedBox(width: 4),
          Text('Stats may change',
              style: GoogleFonts.inter(fontSize: 11, color: C.inkFaint)),
        ]),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _ChoiceCard extends StatefulWidget {
  final dynamic choice;
  final Color dotColor;
  final VoidCallback onTap;
  const _ChoiceCard(
      {required this.choice, required this.dotColor, required this.onTap});

  @override
  State<_ChoiceCard> createState() => _ChoiceCardState();
}

class _ChoiceCardState extends State<_ChoiceCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: _pressed ? C.elevated : C.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: C.div),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(_pressed ? 0.02 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colored dot
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    color: widget.dotColor, shape: BoxShape.circle),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.choice.text,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: C.ink)),
                  const SizedBox(height: 2),
                  Text(_short(widget.choice.outcome),
                      style: GoogleFonts.inter(fontSize: 12, color: C.inkSub)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_outward, size: 16, color: widget.dotColor),
          ],
        ),
      ),
    );
  }

  String _short(String s) {
    final words = s.split(' ');
    return words.length <= 6 ? s : '${words.take(6).join(' ')}…';
  }
}

// ── Outcome screen — star icon + stat changes + Continue ──────────────────────
class _OutcomeScreen extends StatelessWidget {
  final GameState state;
  const _OutcomeScreen({required this.state});

  @override
  Widget build(BuildContext context) {
    final choice = state.lastChoice ??
        Choice(
          text: '',
          outcome: '',
          deltas: StatDeltas(),
        );
    final d = choice.deltas;
    final ch = state.character!;

    // Build stat changes list matching mockup order: Wealth, Happiness, Relationships, Health
    final changes = <_Change>[];
    if (d.wealth != 0) {
      changes.add(_Change('Wealth', d.wealth, C.wealth, _dollarIcon(C.wealth)));
    }
    if (d.happiness != 0) {
      changes.add(_Change('Happiness', d.happiness, C.happy,
          const Icon(Icons.sentiment_satisfied_alt, color: C.happy, size: 16)));
    }
    if (d.relationships != 0) {
      changes.add(_Change('Relationships', d.relationships, C.social,
          const Icon(Icons.people, color: C.social, size: 16)));
    }
    if (d.health != 0) {
      changes.add(_Change('Health', d.health, C.health,
          const Icon(Icons.favorite, color: C.health, size: 16)));
    }
    if (d.moneyDelta != 0) {
      changes.add(_Change(
          'Balance', d.moneyDelta, C.wealth, _dollarIcon(C.wealth),
          isMoney: true));
    }

    return Scaffold(
      backgroundColor: C.surface,
      body: SafeArea(
        child: Column(children: [
          // Top bar: menu + "Age X → Y" + bookmark
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Age ${ch.age}',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: C.ink,
                    )),
              ],
            ),
          ),
          Container(height: 1, color: C.div),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Star in soft green circle
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: C.health.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star_rounded,
                        color: C.health, size: 46),
                  ).animate().scale(
                      begin: const Offset(0.5, 0.5),
                      duration: 400.ms,
                      curve: Curves.elasticOut),

                  const SizedBox(height: 24),

                  Text(choice.text,
                          style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: C.ink,
                              height: 1.3),
                          textAlign: TextAlign.center)
                      .animate()
                      .fadeIn(delay: 200.ms),

                  const SizedBox(height: 8),
                  Text(choice.outcome,
                          style: GoogleFonts.inter(
                              fontSize: 14, color: C.inkSub, height: 1.6),
                          textAlign: TextAlign.center)
                      .animate()
                      .fadeIn(delay: 280.ms),

                  const SizedBox(height: 28),

                  // Stat change rows
                  if (changes.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: C.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: C.div),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: Column(
                        children: changes.asMap().entries.map((e) {
                          final c = e.value;
                          final isLast = e.key == changes.length - 1;
                          final valStr = c.isMoney
                              ? (c.val > 0
                                  ? '+${_money(c.val)}'
                                  : '-${_money(c.val.abs())}')
                              : '${c.val > 0 ? '+' : ''}${c.val}';
                          final isPos = c.val > 0;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                                border: isLast
                                    ? null
                                    : const Border(
                                        bottom: BorderSide(color: C.div))),
                            child: Row(children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                    color: c.color.withOpacity(0.12),
                                    shape: BoxShape.circle),
                                child: Center(child: c.icon),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(c.label,
                                    style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: C.ink)),
                              ),
                              Text(valStr,
                                  style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: isPos ? C.up : C.down)),
                              const SizedBox(width: 4),
                              Icon(
                                isPos
                                    ? Icons.arrow_upward_rounded
                                    : Icons.arrow_downward_rounded,
                                size: 14,
                                color: isPos ? C.up : C.down,
                              ),
                            ]),
                          );
                        }).toList(),
                      ),
                    ).animate().fadeIn(delay: 360.ms).slideY(begin: 0.05),
                ],
              ),
            ),
          ),

          // Continue button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => state.continueLife(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: C.dark,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999)),
                ),
                child: Text('Continue',
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ).animate().fadeIn(delay: 500.ms),
          ),
        ]),
      ),
    );
  }

  Widget _dollarIcon(Color color) => Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: const Center(
            child: Text('\$',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w800))),
      );

  String _money(int v) {
    if (v >= 1000000) return '\$${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '\$${(v / 1000).toStringAsFixed(1)}k';
    return '\$$v';
  }
}

class _Change {
  final String label;
  final int val;
  final Color color;
  final Widget icon;
  final bool isMoney;
  const _Change(this.label, this.val, this.color, this.icon,
      {this.isMoney = false});
}

// ── Landscape scene painter ───────────────────────────────────────────────────
class _LandscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Sun / moon glow
    final sunPaint = Paint()
      ..color = const Color(0xFFFFA040).withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(
        Offset(size.width * 0.6, size.height * 0.3), 45, sunPaint);

    // Distant mountains
    final mtn1 = Paint()..color = const Color(0xFF6878A8).withOpacity(0.7);
    final mtnPath = Path()
      ..moveTo(0, size.height * 0.65)
      ..lineTo(size.width * 0.15, size.height * 0.35)
      ..lineTo(size.width * 0.3, size.height * 0.55)
      ..lineTo(size.width * 0.45, size.height * 0.28)
      ..lineTo(size.width * 0.6, size.height * 0.48)
      ..lineTo(size.width * 0.75, size.height * 0.32)
      ..lineTo(size.width, size.height * 0.50)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(mtnPath, mtn1);

    // Foreground hills
    final hill = Paint()..color = const Color(0xFF3A4860).withOpacity(0.85);
    final hillPath = Path()
      ..moveTo(0, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.62,
          size.width * 0.5, size.height * 0.75)
      ..quadraticBezierTo(
          size.width * 0.75, size.height * 0.88, size.width, size.height * 0.72)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hillPath, hill);

    // Figure silhouette
    final figPaint = Paint()..color = const Color(0xFF1A2030);
    final cx = size.width * 0.5;
    final cy = size.height * 0.7;
    canvas.drawCircle(Offset(cx, cy - 10), 5, figPaint);
    final body = Path()
      ..moveTo(cx - 4, cy - 5)
      ..lineTo(cx + 4, cy - 5)
      ..lineTo(cx + 4, cy + 8)
      ..lineTo(cx - 4, cy + 8)
      ..close();
    canvas.drawPath(body, figPaint);

    // Water / lake reflection
    final waterPaint = Paint()
      ..color = const Color(0xFF6888B8).withOpacity(0.5);
    final waterPath = Path()
      ..moveTo(size.width * 0.1, size.height * 0.82)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.76,
          size.width * 0.7, size.height * 0.80)
      ..quadraticBezierTo(size.width * 0.85, size.height * 0.84,
          size.width * 0.9, size.height * 0.82)
      ..lineTo(size.width * 0.9, size.height * 0.88)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.92,
          size.width * 0.1, size.height * 0.88)
      ..close();
    canvas.drawPath(waterPath, waterPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}
