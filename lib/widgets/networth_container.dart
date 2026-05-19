import 'package:flutter/material.dart';

import '../main.dart';

class NetWorthContainer extends StatefulWidget {
  final int value;

  const NetWorthContainer({
    super.key,
    required this.value,
  });

  @override
  State<NetWorthContainer> createState() => _NetWorthContainerState();
}

class _NetWorthContainerState extends State<NetWorthContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  int _oldValue = 0;

  // TRUE = increasing
  // FALSE = decreasing
  // NULL = unchanged
  bool? _isIncreasing;

  Color get _color {
    // debt always red
    if (widget.value < 0) {
      return Colors.red;
    }

    if (_isIncreasing == true) {
      return Colors.green;
    }

    if (_isIncreasing == false) {
      return Colors.red;
    }

    return C.wealth;
  }

  @override
  void initState() {
    super.initState();

    _oldValue = widget.value;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation = IntTween(
      begin: widget.value,
      end: widget.value,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant NetWorthContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      _oldValue = oldWidget.value;

      // detect increase/decrease
      if (widget.value > oldWidget.value) {
        _isIncreasing = true;
      } else if (widget.value < oldWidget.value) {
        _isIncreasing = false;
      } else {
        _isIncreasing = null;
      }

      // animate value
      _animation = IntTween(
        begin: _oldValue,
        end: widget.value,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOut,
        ),
      );

      _controller
        ..reset()
        ..forward();
    }
  }

  IconData get _icon {
    // debt icon
    if (widget.value < 0) {
      return Icons.warning_rounded;
    }

    if (_isIncreasing == true) {
      return Icons.arrow_upward;
    }

    if (_isIncreasing == false) {
      return Icons.arrow_downward;
    }

    return Icons.remove;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final displayValue = _animation.value;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(
            top: 10,
            bottom: 6,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: C.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _color.withOpacity(0.35),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: _color.withOpacity(0.10),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _icon,
                  color: _color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Net Worth',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.95, end: 1),
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Text(
                  _money(displayValue),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: _color,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _money(int v) {
    final isNegative = v < 0;

    final abs = v.abs();

    String formatted;

    if (abs >= 1000000) {
      formatted = '\$${(abs / 1000000).toStringAsFixed(1)}M';
    } else if (abs >= 1000) {
      formatted = '\$${(abs / 1000).toStringAsFixed(1)}k';
    } else {
      formatted = '\$$abs';
    }

    return isNegative ? '-$formatted' : formatted;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
