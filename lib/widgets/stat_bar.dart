import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

// Full stat card matching mockup — colored icon circle + label + bar + "72 / 100"
class StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final Color bgColor;
  final Widget iconWidget;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
    required this.iconWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: C.div),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Colored circular icon
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Center(child: iconWidget),
          ),
          const SizedBox(width: 12),
          // Label + bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: C.ink)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: value / 100,
                    minHeight: 6,
                    backgroundColor: C.track,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // "72 / 100"
          Text('$value / 100',
              style: GoogleFonts.inter(
                  fontSize: 12, color: C.inkSub, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// Compact bar for death screen
class StatBarCompact extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const StatBarCompact({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(label,
                style: GoogleFonts.inter(fontSize: 13, color: C.deathSub)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: value / 100,
                minHeight: 5,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('$value',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFFCCCCCC),
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// Legacy export for backward compat
class StatBar extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final Color softColor;
  final IconData icon;

  const StatBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.softColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return StatCard(
      label: label,
      value: value,
      color: color,
      bgColor: softColor,
      iconWidget: Icon(icon, color: color, size: 16),
    );
  }
}
