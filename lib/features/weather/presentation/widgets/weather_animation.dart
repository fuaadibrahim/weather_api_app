import 'dart:math' as math;

import 'package:flutter/material.dart';

class WeatherAnimation extends StatefulWidget {
  final String? condition;
  final String? iconCode;
  final bool isLoading;
  final double size;

  const WeatherAnimation({
    super.key,
    required this.condition,
    required this.iconCode,
    required this.isLoading,
    this.size = 240,
  });

  @override
  State<WeatherAnimation> createState() => _WeatherAnimationState();
}

class _WeatherAnimationState extends State<WeatherAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          if (widget.isLoading) {
            return buildLoadingAnimation();
          }

          final condition = widget.condition?.toLowerCase();
          final isNight = widget.iconCode?.endsWith('n') ?? false;

          switch (condition) {
            case 'clear':
              return isNight ? buildNightAnimation() : buildSunAnimation();

            case 'rain':
            case 'drizzle':
              return buildRainAnimation();

            case 'thunderstorm':
              return buildThunderAnimation();

            case 'snow':
              return buildSnowAnimation();

            case 'mist':
            case 'fog':
            case 'haze':
            case 'smoke':
              return buildFogAnimation();

            case 'clouds':
              return buildCloudAnimation();

            default:
              return buildCloudAnimation();
          }
        },
      ),
    );
  }

  Widget buildLoadingAnimation() {
    final value = controller.value;

    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.rotate(
          angle: value * math.pi * 2,
          child: Container(
            width: widget.size * 0.68,
            height: widget.size * 0.68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 2,
              ),
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Color(0xFFB8E7FF),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
        Transform.translate(
          offset: Offset(
            math.sin(value * math.pi * 2) * 9,
            math.cos(value * math.pi * 2) * 3,
          ),
          child: Icon(
            Icons.cloud_rounded,
            color: Colors.white,
            size: widget.size * 0.42,
          ),
        ),
        Positioned(
          bottom: widget.size * 0.22,
          child: SizedBox(
            width: widget.size * 0.42,
            child: LinearProgressIndicator(
              value: null,
              minHeight: 3,
              color: const Color(0xFFB8E7FF),
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSunAnimation() {
    final value = controller.value;
    final pulse = 1 + math.sin(value * math.pi * 2) * 0.055;

    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.rotate(
          angle: value * math.pi * 2,
          child: Icon(
            Icons.wb_sunny_rounded,
            color: const Color(0xFFFFD36A).withValues(alpha: 0.32),
            size: widget.size * 0.78,
          ),
        ),
        Transform.scale(
          scale: pulse,
          child: Container(
            width: widget.size * 0.39,
            height: widget.size * 0.39,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFD36A),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD36A).withValues(alpha: 0.35),
                  blurRadius: 35,
                  spreadRadius: 8,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: widget.size * 0.10,
          bottom: widget.size * 0.18,
          child: Transform.translate(
            offset: Offset(math.sin(value * math.pi * 2) * 12, 0),
            child: Icon(
              Icons.cloud_rounded,
              color: Colors.white.withValues(alpha: 0.88),
              size: widget.size * 0.30,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildNightAnimation() {
    final value = controller.value;

    return Stack(
      alignment: Alignment.center,
      children: [
        ...List.generate(7, (index) {
          final angle = (index / 7) * math.pi * 2;
          final radius = widget.size * (0.27 + (index % 2) * 0.07);
          final sparkle =
              0.45 + ((math.sin(value * math.pi * 2 + index) + 1) / 2) * 0.55;

          return Transform.translate(
            offset: Offset(math.cos(angle) * radius, math.sin(angle) * radius),
            child: Opacity(
              opacity: sparkle.clamp(0.0, 1.0).toDouble(),
              child: Icon(
                Icons.star_rounded,
                color: Colors.white,
                size: 9 + (index % 3) * 3,
              ),
            ),
          );
        }),
        Transform.rotate(
          angle: -0.20 + math.sin(value * math.pi * 2) * 0.03,
          child: Icon(
            Icons.nightlight_round,
            color: const Color(0xFFFFE8A3),
            size: widget.size * 0.52,
          ),
        ),
        Positioned(
          bottom: widget.size * 0.18,
          right: widget.size * 0.08,
          child: Transform.translate(
            offset: Offset(math.sin(value * math.pi * 2) * 10, 0),
            child: Icon(
              Icons.cloud_rounded,
              color: Colors.white.withValues(alpha: 0.82),
              size: widget.size * 0.32,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildCloudAnimation() {
    final value = controller.value;

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: widget.size * 0.25,
          left: widget.size * 0.06,
          child: Transform.translate(
            offset: Offset(math.sin(value * math.pi * 2) * 18, 0),
            child: Icon(
              Icons.cloud_rounded,
              color: Colors.white.withValues(alpha: 0.42),
              size: widget.size * 0.42,
            ),
          ),
        ),
        Transform.translate(
          offset: Offset(
            math.sin((value + 0.35) * math.pi * 2) * 9,
            math.cos(value * math.pi * 2) * 4,
          ),
          child: Icon(
            Icons.cloud_rounded,
            color: Colors.white,
            size: widget.size * 0.60,
          ),
        ),
        Positioned(
          bottom: widget.size * 0.20,
          right: widget.size * 0.06,
          child: Transform.translate(
            offset: Offset(math.sin((value + 0.65) * math.pi * 2) * 15, 0),
            child: Icon(
              Icons.cloud_rounded,
              color: const Color(0xFFD8F2FF).withValues(alpha: 0.74),
              size: widget.size * 0.33,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildRainAnimation() {
    final value = controller.value;

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: widget.size * 0.18,
          child: Transform.translate(
            offset: Offset(math.sin(value * math.pi * 2) * 8, 0),
            child: Icon(
              Icons.cloud_rounded,
              color: Colors.white,
              size: widget.size * 0.57,
            ),
          ),
        ),
        ...List.generate(7, (index) {
          final progress = (value + index / 7) % 1;
          final left = widget.size * (0.25 + index * 0.085);
          final top = widget.size * (0.48 + progress * 0.30);

          return Positioned(
            left: left,
            top: top,
            child: Transform.rotate(
              angle: 0.28,
              child: Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF9DDBFF,
                  ).withValues(alpha: (1 - progress) * 0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget buildThunderAnimation() {
    final value = controller.value;
    final flash = value > 0.12 && value < 0.22;

    return Stack(
      alignment: Alignment.center,
      children: [
        if (flash)
          Container(
            width: widget.size * 0.82,
            height: widget.size * 0.82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.13),
            ),
          ),
        Positioned(
          top: widget.size * 0.16,
          child: Icon(
            Icons.cloud_rounded,
            color: Colors.white,
            size: widget.size * 0.58,
          ),
        ),
        Positioned(
          top: widget.size * 0.45,
          child: Transform.scale(
            scale: 0.95 + math.sin(value * math.pi * 4).abs() * 0.08,
            child: Icon(
              Icons.bolt_rounded,
              color: const Color(0xFFFFD25A),
              size: widget.size * 0.35,
            ),
          ),
        ),
        ...List.generate(4, (index) {
          final progress = (value + index / 4) % 1;

          return Positioned(
            left: widget.size * (0.27 + index * 0.14),
            top: widget.size * (0.57 + progress * 0.24),
            child: Container(
              width: 4,
              height: 15,
              decoration: BoxDecoration(
                color: const Color(
                  0xFF9DDBFF,
                ).withValues(alpha: (1 - progress) * 0.85),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget buildSnowAnimation() {
    final value = controller.value;

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: widget.size * 0.15,
          child: Icon(
            Icons.cloud_rounded,
            color: Colors.white,
            size: widget.size * 0.56,
          ),
        ),
        ...List.generate(10, (index) {
          final progress = (value + index / 10) % 1;
          final wave = math.sin(value * math.pi * 2 + index);

          return Positioned(
            left: widget.size * (0.16 + (index % 5) * 0.16) + wave * 5,
            top: widget.size * (0.46 + progress * 0.36),
            child: Opacity(
              opacity: (1 - progress * 0.65).clamp(0.0, 1.0).toDouble(),
              child: Icon(
                Icons.ac_unit_rounded,
                color: Colors.white,
                size: 11 + (index % 3) * 3,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget buildFogAnimation() {
    final value = controller.value;

    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.cloud_rounded,
          color: Colors.white.withValues(alpha: 0.92),
          size: widget.size * 0.50,
        ),
        ...List.generate(5, (index) {
          final direction = index.isEven ? 1.0 : -1.0;
          final movement =
              math.sin(value * math.pi * 2 + index) * 18 * direction;

          return Positioned(
            top: widget.size * (0.55 + index * 0.055),
            child: Transform.translate(
              offset: Offset(movement, 0),
              child: Container(
                width: widget.size * (0.54 - index * 0.035),
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.50 - index * 0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
