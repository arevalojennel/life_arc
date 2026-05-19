import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/game_state.dart';
import 'game_screen.dart';

class CharacterCreationScreen extends StatefulWidget {
  const CharacterCreationScreen({super.key});

  @override
  State<CharacterCreationScreen> createState() => _State();
}

class _State extends State<CharacterCreationScreen> {
  final _nameCtrl = TextEditingController(text: 'Alex Morgan');
  final _formKey = GlobalKey<FormState>();
  int _traitIdx = 0;

  final _traits = [
    {
      'icon': '✦',
      'name': 'Optimistic',
      'desc': 'You start life with a positive outlook.'
    },
    {
      'icon': '🌍',
      'name': 'Adventurous',
      'desc': 'You crave exploration and new experiences.'
    },
    {
      'icon': '🚀',
      'name': 'Ambitious',
      'desc': 'You are driven to achieve great things.'
    },
    {
      'icon': '🛡️',
      'name': 'Cautious',
      'desc': 'You think carefully before every decision.'
    },
    {
      'icon': '🎨',
      'name': 'Creative',
      'desc': 'You see the world through an artist\'s eyes.'
    },
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _start() {
    if (_formKey.currentState!.validate()) {
      context
          .read<GameState>()
          .startNewGame(_nameCtrl.text.trim(), _traits[_traitIdx]['name']!);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const GameScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final trait = _traits[_traitIdx];
    return Scaffold(
      backgroundColor: C.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Back arrow
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, size: 20, color: C.ink),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Title
                      Text('Create Your Character',
                          style: GoogleFonts.inter(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: C.ink)),
                      const SizedBox(height: 32),

                      // Circular avatar with illustrated face + pencil
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFEDE8DF),
                              border: Border.all(color: C.div, width: 2),
                            ),
                            child: ClipOval(
                              child: CustomPaint(
                                painter: _FacePainter(),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: C.dark,
                                shape: BoxShape.circle,
                                border: Border.all(color: C.surface, width: 2),
                              ),
                              child: const Icon(Icons.edit,
                                  size: 13, color: Colors.white),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 36),

                      // Name field
                      _fieldLabel('Name'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameCtrl,
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            color: C.ink,
                            fontWeight: FontWeight.w500),
                        cursorColor: C.dark,
                        decoration: _inputDeco('Alex Morgan'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter a name.'
                            : null,
                      ),

                      const SizedBox(height: 22),

                      // Starting Trait
                      _fieldLabel('Starting Trait'),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _pickTrait,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 13),
                          decoration: BoxDecoration(
                            color: C.surface,
                            border: Border.all(color: C.div, width: 1.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(children: [
                            Text(trait['icon']!,
                                style: const TextStyle(fontSize: 17)),
                            const SizedBox(width: 10),
                            Text(trait['name']!,
                                style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: C.ink)),
                            const Spacer(),
                            const Icon(Icons.keyboard_arrow_down,
                                color: C.inkFaint, size: 20),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(trait['desc']!,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: C.inkSub,
                                fontStyle: FontStyle.italic)),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom area: button + dots
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
              child: Column(children: [
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _start,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: C.dark,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999)),
                    ),
                    child: Text('Begin Life',
                        style: GoogleFonts.inter(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Text(text,
            style: GoogleFonts.inter(
                fontSize: 12, color: C.inkSub, fontWeight: FontWeight.w500)),
      );

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: C.inkFaint, fontSize: 15),
        filled: true,
        fillColor: C.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: C.div, width: 1.5)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: C.dark, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red)),
      );

  void _pickTrait() {
    showModalBottomSheet(
      context: context,
      backgroundColor: C.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: C.div, borderRadius: BorderRadius.circular(999))),
          const SizedBox(height: 8),
          ..._traits.asMap().entries.map((e) => ListTile(
                leading: Text(e.value['icon']!,
                    style: const TextStyle(fontSize: 20)),
                title: Text(e.value['name']!,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: C.ink,
                        fontSize: 14)),
                subtitle: Text(e.value['desc']!,
                    style: GoogleFonts.inter(fontSize: 12, color: C.inkSub)),
                trailing: e.key == _traitIdx
                    ? const Icon(Icons.check_circle, color: C.dark, size: 20)
                    : null,
                onTap: () {
                  setState(() => _traitIdx = e.key);
                  Navigator.pop(ctx);
                },
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// Simple illustrated face painter
class _FacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Neck + shoulders
    final bodyPaint = Paint()..color = const Color(0xFFD4A882);
    canvas.drawRect(Rect.fromLTWH(cx - 12, cy + 18, 24, 16), bodyPaint);
    final shirt = Paint()..color = const Color(0xFF4A5568);
    canvas.drawRect(Rect.fromLTWH(cx - 24, cy + 30, 48, 20), shirt);

    // Face
    final facePaint = Paint()..color = const Color(0xFFDDAA88);
    canvas.drawCircle(Offset(cx, cy + 4), 28, facePaint);

    // Hair (dark)
    final hair = Paint()..color = const Color(0xFF2D1B0E);
    final hairPath = Path()
      ..moveTo(cx - 28, cy + 4)
      ..arcTo(Rect.fromCircle(center: Offset(cx, cy + 4), radius: 28), 3.14,
          3.14, false)
      ..lineTo(cx + 26, cy - 10)
      ..quadraticBezierTo(cx + 24, cy - 20, cx + 16, cy - 22)
      ..quadraticBezierTo(cx, cy - 30, cx - 16, cy - 22)
      ..quadraticBezierTo(cx - 24, cy - 20, cx - 26, cy - 10)
      ..close();
    canvas.drawPath(hairPath, hair);

    // Eyes
    final eyePaint = Paint()..color = const Color(0xFF2D1B0E);
    canvas.drawCircle(Offset(cx - 9, cy + 4), 3.5, eyePaint);
    canvas.drawCircle(Offset(cx + 9, cy + 4), 3.5, eyePaint);
    // Eye shine
    final shinePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx - 8, cy + 3), 1.2, shinePaint);
    canvas.drawCircle(Offset(cx + 10, cy + 3), 1.2, shinePaint);

    // Smile
    final smilePaint = Paint()
      ..color = const Color(0xFFC07850)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
        Rect.fromCenter(center: Offset(cx, cy + 10), width: 14, height: 8),
        0.1,
        2.9,
        false,
        smilePaint);
  }

  @override
  bool shouldRepaint(_) => false;
}
