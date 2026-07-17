import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

/// A widget that applies a springy scale-down effect on touch.
/// Ideal for cards, buttons, and list items.
class SpringyTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;
  final Duration duration;

  const SpringyTap({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.95,
    this.duration = const Duration(milliseconds: 100),
  });

  @override
  State<SpringyTap> createState() => _SpringyTapState();
}

class _SpringyTapState extends State<SpringyTap> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse();
      widget.onTap!();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Directions supported by the entry slide animation.
enum SlideDirection {
  up,
  down,
  left,
  right,
}

/// A widget that applies a fade and slide translation upon mounting.
/// Useful for cascading staggered animations on pages.
class FadeInSlide extends StatefulWidget {
  final Widget child;
  final SlideDirection direction;
  final double offset;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  const FadeInSlide({
    super.key,
    required this.child,
    this.direction = SlideDirection.up,
    this.offset = 30.0,
    this.duration = const Duration(milliseconds: 600),
    this.delay = Duration.zero,
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<FadeInSlide> createState() => _FadeInSlideState();
}

class _FadeInSlideState extends State<FadeInSlide> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    Offset startOffset;
    switch (widget.direction) {
      case SlideDirection.up:
        startOffset = Offset(0, widget.offset);
        break;
      case SlideDirection.down:
        startOffset = Offset(0, -widget.offset);
        break;
      case SlideDirection.left:
        startOffset = Offset(widget.offset, 0);
        break;
      case SlideDirection.right:
        startOffset = Offset(-widget.offset, 0);
        break;
    }

    _slideAnimation = Tween<Offset>(
      begin: startOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: _slideAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// A widget that continuously pulses the scale and/or opacity of its child.
class AnimatedPulse extends StatefulWidget {
  final Widget child;
  final double minScale;
  final double maxScale;
  final Duration duration;
  final bool pulseOpacity;

  const AnimatedPulse({
    super.key,
    required this.child,
    this.minScale = 0.95,
    this.maxScale = 1.05,
    this.duration = const Duration(seconds: 2),
    this.pulseOpacity = false,
  });

  @override
  State<AnimatedPulse> createState() => _AnimatedPulseState();
}

class _AnimatedPulseState extends State<AnimatedPulse> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget result = ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );

    if (widget.pulseOpacity) {
      result = FadeTransition(
        opacity: _opacityAnimation,
        child: result,
      );
    }

    return result;
  }
}

/// A PageRoute that transitions by fading and sliding up,
/// matching the entry animations of components like FadeInSlide.
class FadeInSlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeInSlidePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 550),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
              ),
            );

            final slideAnimation = Tween<Offset>(
              begin: const Offset(0.0, 0.15),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            );

            return FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: slideAnimation,
                child: child,
              ),
            );
          },
        );
}

/// A premium animated background with slowly floating, pulsing, blurred bubbles.
/// Ideal for high-end gaming hubs or dashboard screens.
class AnimatedBubbleBackground extends StatefulWidget {
  final Widget child;
  final List<Color> colors;

  const AnimatedBubbleBackground({
    super.key,
    required this.child,
    this.colors = const [
      Color(0xFF7C4DFF),
      Color(0xFF00BCD4),
      Color(0xFFFF5722),
      Color(0xFF4CAF50),
    ],
  });

  @override
  State<AnimatedBubbleBackground> createState() => _AnimatedBubbleBackgroundState();
}

class _AnimatedBubbleBackgroundState extends State<AnimatedBubbleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_FloatingBubble> _bubbles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bubbles.isEmpty) {
      final size = MediaQuery.sizeOf(context);
      final r = size.width;
      
      // Initialize floating bubbles with varying sizes, speeds and color biases
      _bubbles.addAll([
        _FloatingBubble(
          baseX: r * 0.15,
          baseY: size.height * 0.25,
          radius: r * 0.35,
          speed: 1.0,
          color: widget.colors[0].withValues(alpha: 0.15),
          offsetRange: const Offset(40, 50),
        ),
        _FloatingBubble(
          baseX: r * 0.85,
          baseY: size.height * 0.12,
          radius: r * 0.45,
          speed: 0.8,
          color: widget.colors[1].withValues(alpha: 0.15),
          offsetRange: const Offset(50, 40),
        ),
        _FloatingBubble(
          baseX: r * 0.50,
          baseY: size.height * 0.65,
          radius: r * 0.40,
          speed: 1.2,
          color: widget.colors[2].withValues(alpha: 0.12),
          offsetRange: const Offset(60, 45),
        ),
        _FloatingBubble(
          baseX: r * 0.20,
          baseY: size.height * 0.85,
          radius: r * 0.38,
          speed: 0.95,
          color: widget.colors[3].withValues(alpha: 0.14),
          offsetRange: const Offset(45, 55),
        ),
      ]);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The animated background canvas
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _BubbleBackgroundPainter(
                  bubbles: _bubbles,
                  progress: _controller.value,
                ),
              );
            },
          ),
        ),
        // Glassmorphism overlay
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        // Forefront child
        widget.child,
      ],
    );
  }
}

class _FloatingBubble {
  final double baseX;
  final double baseY;
  final double radius;
  final double speed;
  final Color color;
  final Offset offsetRange;

  const _FloatingBubble({
    required this.baseX,
    required this.baseY,
    required this.radius,
    required this.speed,
    required this.color,
    required this.offsetRange,
  });
}

class _BubbleBackgroundPainter extends CustomPainter {
  final List<_FloatingBubble> bubbles;
  final double progress;

  const _BubbleBackgroundPainter({required this.bubbles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final bubble in bubbles) {
      // Smooth dynamic oscillation movement
      final double dynamicX = bubble.baseX + (bubble.offsetRange.dx * (progress < 0.5 ? progress : 1.0 - progress) * 0.5);
      final double dynamicY = bubble.baseY + (bubble.offsetRange.dy * (progress < 0.5 ? 1.0 - progress : progress) * 0.5);

      paint.color = bubble.color;
      canvas.drawCircle(Offset(dynamicX, dynamicY), bubble.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BubbleBackgroundPainter oldDelegate) => true;
}

