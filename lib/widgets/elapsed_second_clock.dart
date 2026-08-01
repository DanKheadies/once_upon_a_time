import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Reports elapsed seconds since it was created, ticking every frame.
///
/// Use this instead of AnimationController when you want a raw, unbounded
/// clock (e.g. to feed a shader's `uTime` uniform) rather than a 0..1 tween —
/// AnimationController's `.value` is designed around bounded animations and
/// fighting that abstraction for a free-running clock is more trouble than
/// it's worth.
///
/// It's a ValueListenable<double>, so it works directly as CustomPainter's
/// `repaint:` argument and exposes `.value` for reading current time.
class ElapsedSecondsClock extends ValueNotifier<double> {
  ElapsedSecondsClock() : super(0.0) {
    _ticker = Ticker(_onTick)..start();
  }

  late final Ticker _ticker;

  void _onTick(Duration elapsed) {
    value = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
  }

  /// Call from dispose() of whatever State owns this clock.
  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}
