import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Confetti celebration overlay for goal achievement
class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  final bool celebrate;
  final VoidCallback? onCelebrationComplete;

  const ConfettiOverlay({
    super.key,
    required this.child,
    required this.celebrate,
    this.onCelebrationComplete,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> {
  late ConfettiController _controller;
  bool _hasTriggered = false;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 3));
    _controller.addListener(_onConfettiStateChange);
  }

  void _onConfettiStateChange() {
    if (_controller.state == ConfettiControllerState.stopped && _hasTriggered) {
      widget.onCelebrationComplete?.call();
    }
  }

  @override
  void didUpdateWidget(ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.celebrate && !oldWidget.celebrate && !_hasTriggered) {
      _hasTriggered = true;
      _controller.play();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onConfettiStateChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Center confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _controller,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              AppTheme.primaryTeal,
              AppTheme.primaryTealLight,
              AppTheme.accentOrange,
              AppTheme.accentOrangeLight,
              AppTheme.success,
              Colors.white,
            ],
            numberOfParticles: 30,
            maxBlastForce: 50,
            minBlastForce: 20,
            emissionFrequency: 0.05,
            gravity: 0.2,
            particleDrag: 0.05,
            createParticlePath: _drawStar,
          ),
        ),
      ],
    );
  }

  Path _drawStar(Size size) {
    // Create a star or circle shape randomly
    final random = Random();
    if (random.nextBool()) {
      // Circle
      return Path()
        ..addOval(Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: size.width / 2,
        ));
    } else {
      // Star
      final double width = size.width;
      final double halfWidth = width / 2;
      final double bigHeight = halfWidth * tan(degreesToRadians(36).toDouble());
      final double smallHeight = halfWidth * tan(degreesToRadians(18).toDouble());
      final double height = 2 * bigHeight + smallHeight;

      return Path()
        ..moveTo(halfWidth, 0)
        ..lineTo(halfWidth + smallHeight * tan(degreesToRadians(36).toDouble()), bigHeight)
        ..lineTo(width, bigHeight)
        ..lineTo(halfWidth + smallHeight / cos(degreesToRadians(36).toDouble()), bigHeight + smallHeight)
        ..lineTo(halfWidth + bigHeight * tan(degreesToRadians(36).toDouble()), height)
        ..lineTo(halfWidth, bigHeight + smallHeight)
        ..lineTo(halfWidth - bigHeight * tan(degreesToRadians(36).toDouble()), height)
        ..lineTo(halfWidth - smallHeight / cos(degreesToRadians(36).toDouble()), bigHeight + smallHeight)
        ..lineTo(0, bigHeight)
        ..lineTo(halfWidth - smallHeight * tan(degreesToRadians(36).toDouble()), bigHeight)
        ..close();
    }
  }

  num degreesToRadians(num degrees) => degrees * (pi / 180);
}

/// Simple confetti trigger widget
class ConfettiTrigger extends StatefulWidget {
  final Widget child;
  final bool trigger;

  const ConfettiTrigger({
    super.key,
    required this.child,
    required this.trigger,
  });

  @override
  State<ConfettiTrigger> createState() => _ConfettiTriggerState();
}

class _ConfettiTriggerState extends State<ConfettiTrigger> {
  late ConfettiController _leftController;
  late ConfettiController _rightController;
  bool _hasTriggered = false;

  @override
  void initState() {
    super.initState();
    _leftController = ConfettiController(duration: const Duration(seconds: 2));
    _rightController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void didUpdateWidget(ConfettiTrigger oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !_hasTriggered) {
      _hasTriggered = true;
      _leftController.play();
      _rightController.play();
    }
  }

  @override
  void dispose() {
    _leftController.dispose();
    _rightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Left side confetti
        Align(
          alignment: Alignment.topLeft,
          child: ConfettiWidget(
            confettiController: _leftController,
            blastDirection: -pi / 4, // Diagonal right
            shouldLoop: false,
            colors: const [
              AppTheme.primaryTeal,
              AppTheme.primaryTealLight,
              AppTheme.accentOrange,
              AppTheme.success,
            ],
            numberOfParticles: 15,
            maxBlastForce: 40,
            minBlastForce: 15,
            emissionFrequency: 0.1,
            gravity: 0.3,
          ),
        ),
        // Right side confetti
        Align(
          alignment: Alignment.topRight,
          child: ConfettiWidget(
            confettiController: _rightController,
            blastDirection: -3 * pi / 4, // Diagonal left
            shouldLoop: false,
            colors: const [
              AppTheme.primaryTeal,
              AppTheme.primaryTealLight,
              AppTheme.accentOrange,
              AppTheme.success,
            ],
            numberOfParticles: 15,
            maxBlastForce: 40,
            minBlastForce: 15,
            emissionFrequency: 0.1,
            gravity: 0.3,
          ),
        ),
      ],
    );
  }
}
