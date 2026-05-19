import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lifearc/screens/stat_screen.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/game_state.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ch = context.watch<GameState>().character;

    return Scaffold(
      backgroundColor: C.surface,
      appBar: AppBar(
        backgroundColor: C.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: C.ink, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Life History',
            style: GoogleFonts.inter(
                fontSize: 17, fontWeight: FontWeight.w700, color: C.ink)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tab,
          labelStyle:
              GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 14),
          labelColor: C.ink,
          unselectedLabelColor: C.inkFaint,
          indicatorColor: C.ink,
          indicatorWeight: 2,
          tabs: const [Tab(text: 'Timeline'), Tab(text: 'Stats')],
        ),
      ),
      body: ch == null
          ? Center(
              child: Text('No life started.',
                  style: GoogleFonts.inter(color: C.inkSub)))
          : TabBarView(
              controller: _tab,
              children: [
                _TimelineTab(events: ch.lifeEvents),
                Consumer<GameState>(
                  builder: (_, state, __) {
                    final ch = state.character;
                    if (ch == null) return const SizedBox();

                    return Consumer<GameState>(
                      builder: (_, state, __) {
                        final ch = state.character;
                        if (ch == null) return const SizedBox();

                        return StatsBody(
                          key:
                              ValueKey(ch.healthHistory.length), // 🔥 IMPORTANT
                          character: ch,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
    );
  }
}

class _TimelineTab extends StatelessWidget {
  final List<String> events;
  const _TimelineTab({required this.events});

  // Each event gets a colored circle with an icon, matching mockup icons:
  static const _configs = [
    {'color': C.health, 'icon': Icons.school_outlined}, // graduation
    {'color': C.happy, 'icon': Icons.explore_outlined}, // travel
    {'color': C.wealth, 'icon': Icons.work_outline}, // job
    {'color': C.social, 'icon': Icons.favorite_border}, // relationship
    {
      'color': Color(0xFFFFA726),
      'icon': Icons.celebration_outlined
    }, // marriage
    {'color': C.health, 'icon': Icons.child_care_outlined}, // child
    {'color': C.social, 'icon': Icons.star_border}, // achievement
  ];

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_stories_outlined, size: 48, color: C.inkFaint),
          const SizedBox(height: 12),
          Text('No events yet.',
              style: GoogleFonts.inter(color: C.inkSub, fontSize: 14)),
        ],
      ));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      itemCount: events.length,
      itemBuilder: (ctx, i) {
        final cfg = _configs[i % _configs.length];
        final color = cfg['color'] as Color;
        final icon = cfg['icon'] as IconData;
        final raw = events[i];

        // Parse: "Age X: Title — Choice"
        String ageLabel = '', title = raw, detail = '';
        final ci = raw.indexOf(':');
        if (ci != -1) {
          ageLabel = raw.substring(0, ci).trim();
          final rest = raw.substring(ci + 1).trim();
          final di = rest.indexOf('—');
          if (di != -1) {
            title = rest.substring(0, di).trim();
            detail = rest.substring(di + 1).trim();
          } else {
            title = rest;
          }
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline: icon circle + vertical line
            Column(children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: color.withOpacity(0.13), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 18),
              ),
              if (i < events.length - 1)
                Container(width: 2, height: 50, color: C.div),
            ]),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (ageLabel.isNotEmpty)
                      Text(ageLabel,
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: C.inkFaint,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3)),
                    const SizedBox(height: 2),
                    Text(title,
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: C.ink,
                            height: 1.3)),
                    if (detail.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(detail,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: color,
                              fontWeight: FontWeight.w500)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
