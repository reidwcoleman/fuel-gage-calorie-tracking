import 'package:flutter/material.dart';

/// Animated counter that smoothly transitions between values
class AnimatedCounter extends StatelessWidget {
  final int value;
  final Duration duration;
  final TextStyle? style;
  final String? prefix;
  final String? suffix;
  final Curve curve;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 500),
    this.style,
    this.prefix,
    this.suffix,
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: value.toDouble(), end: value.toDouble()),
      duration: duration,
      curve: curve,
      builder: (context, animatedValue, child) {
        return Text(
          '${prefix ?? ''}${animatedValue.round()}${suffix ?? ''}',
          style: style,
        );
      },
    );
  }
}

/// Animated counter that tracks and animates from previous value
class AnimatedCounterStateful extends StatefulWidget {
  final int value;
  final Duration duration;
  final TextStyle? style;
  final String? prefix;
  final String? suffix;
  final Curve curve;

  const AnimatedCounterStateful({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 600),
    this.style,
    this.prefix,
    this.suffix,
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<AnimatedCounterStateful> createState() => _AnimatedCounterStatefulState();
}

class _AnimatedCounterStatefulState extends State<AnimatedCounterStateful>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.value.toDouble();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: _previousValue,
      end: widget.value.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
  }

  @override
  void didUpdateWidget(AnimatedCounterStateful oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = _animation.value;
      _animation = Tween<double>(
        begin: _previousValue,
        end: widget.value.toDouble(),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${widget.prefix ?? ''}${_animation.value.round()}${widget.suffix ?? ''}',
          style: widget.style,
        );
      },
    );
  }
}

/// Animated percentage counter with decimal precision
class AnimatedPercentage extends StatefulWidget {
  final double value;
  final int decimalPlaces;
  final Duration duration;
  final TextStyle? style;
  final TextStyle? percentStyle;
  final Curve curve;

  const AnimatedPercentage({
    super.key,
    required this.value,
    this.decimalPlaces = 0,
    this.duration = const Duration(milliseconds: 600),
    this.style,
    this.percentStyle,
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<AnimatedPercentage> createState() => _AnimatedPercentageState();
}

class _AnimatedPercentageState extends State<AnimatedPercentage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.value;
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: _previousValue,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedPercentage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = _animation.value;
      _animation = Tween<double>(
        begin: _previousValue,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final displayValue = _animation.value.toStringAsFixed(widget.decimalPlaces);
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              displayValue,
              style: widget.style,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '%',
                style: widget.percentStyle ?? widget.style?.copyWith(
                  fontSize: (widget.style?.fontSize ?? 24) * 0.35,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
