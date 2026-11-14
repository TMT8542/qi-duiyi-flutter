import 'dart:math' as math;
import 'package:flutter/physics.dart';

/// 弹簧物理：与 jicun 的 SpringDescription.withDurationAndBounce 同一套换算
class GlassSpring {
  static const double kDefaultDuration = 0.32;
  static const double kDefaultBounce = 0.18;

  final double mass;
  final double stiffness;
  final double damping;

  const GlassSpring({required this.mass, required this.stiffness, required this.damping});

  factory GlassSpring.fromDurationAndBounce({required double duration, required double bounce}) {
    const double m = 1.0;
    final double zeta = 1.0 - bounce;
    final double omega = math.pi / (duration * (1.0 - bounce));
    return GlassSpring(mass: m, stiffness: omega * omega * m, damping: 2.0 * zeta * omega * m);
  }

  static final GlassSpring standard =
      GlassSpring.fromDurationAndBounce(duration: kDefaultDuration, bounce: kDefaultBounce);

  static final GlassSpring indicator =
      GlassSpring.fromDurationAndBounce(duration: 0.28, bounce: 0.14);

  SpringDescription get description =>
      SpringDescription(mass: mass, stiffness: stiffness, damping: damping);

  SpringSimulation simulation(double from, double to, double velocity) =>
      SpringSimulation(description, from, to, velocity);
}
