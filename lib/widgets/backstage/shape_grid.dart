import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Precomputed, immutable instance layout. Build this ONCE (not inside
/// build()) and hand it down — regenerating positions every frame would
/// defeat the whole point.
class ShapeInstanceLayout {
  ShapeInstanceLayout._(
    this.positions,
    this.timeOffsets,
    this.instanceScale,
    this.shaders, {
    this.logoImage,
    this.velocities,
  });

  final List<Offset> positions; // normalized 0..1 within the widget's bounds
  final List<double> timeOffsets; // seconds, desyncs each shape's cycle
  final double instanceScale; // px "radius" per shape
  final List<ui.FragmentShader> shaders;

  /// Held here so it isn't garbage collected while a shader is still
  /// sampling it — setImageSampler() binds the texture, but doesn't by
  /// itself keep the Dart-side ui.Image object alive.
  final ui.Image? logoImage;

  /// Normalized units/second, e.g. 0.1 == crosses 10% of the canvas per
  /// second. Null for static (.grid / .chaotic) layouts — advance() is then
  /// a no-op.
  final List<Offset>? velocities;

  double _lastTime = 0;
  bool _initialized = false;

  /// DVD-logo style: random start positions, random constant-velocity
  /// directions, reflecting off the canvas edges.
  factory ShapeInstanceLayout.bouncing({
    required ui.FragmentProgram program,
    required int count,
    double instanceScale = 14,
    double minSpeed = 0.08, // normalized units/sec
    double maxSpeed = 0.22,
    int seed = 7,
    Color shapeColor = const Color(0xFFF28C26),
    Color backgroundColor = const Color(0x00000000),
    ui.Image? logoImage,
  }) {
    final rnd = Random(seed);
    final positions = List.generate(
      count,
      (_) => Offset(rnd.nextDouble(), rnd.nextDouble()),
    );
    final velocities = List.generate(count, (_) {
      final angle = rnd.nextDouble() * 2 * pi;
      final speed = minSpeed + rnd.nextDouble() * (maxSpeed - minSpeed);
      return Offset(cos(angle), sin(angle)) * speed;
    });
    final offsets = List.generate(count, (_) => rnd.nextDouble() * 4.0);
    final shaders = List.generate(
      count,
      (_) => _makeShader(
        shapeColor,
        backgroundColor,
        program,
        logoImage: logoImage,
        // random: rnd,
        // shapeColors: [Colors.red, Colors.white, Colors.lightBlue],
      ),
    );
    return ShapeInstanceLayout._(
      positions,
      offsets,
      instanceScale,
      shaders,
      logoImage: logoImage,
      velocities: velocities,
    );
  }

  factory ShapeInstanceLayout.chaotic({
    required ui.FragmentProgram program,
    required int count,
    int seed = 42, // fixed seed keeps layout stable across hot reloads
    double instanceScale = 14,
    Color shapeColor = const Color(0xFFF28C26), // the old default orange
    Color backgroundColor = const Color(0x00000000), // transparent
  }) {
    final rnd = Random(seed);
    final positions = List.generate(
      count,
      (_) => Offset(rnd.nextDouble(), rnd.nextDouble()),
    );
    final offsets = List.generate(count, (_) => rnd.nextDouble() * 4.0);
    final shaders = List.generate(
      count,
      (_) => _makeShader(
        shapeColor,
        backgroundColor,
        program,
        random: rnd,
        shapeColors: [
          Colors.deepPurpleAccent,
          Colors.green,
          Colors.yellow,
          Colors.teal.shade300,
          Colors.pink.withAlpha(100),
        ],
      ),
    );

    return ShapeInstanceLayout._(positions, offsets, instanceScale, shaders);
  }

  factory ShapeInstanceLayout.grid({
    required ui.FragmentProgram program,
    required int columns,
    required int rows,
    double instanceScale = 14,
    Color shapeColor = const Color(0xFFF28C26), // the old default orange
    Color backgroundColor = const Color(0x00000000), // transparent
  }) {
    final positions = <Offset>[];
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < columns; x++) {
        positions.add(Offset((x + 0.5) / columns, (y + 0.5) / rows));
      }
    }
    final offsets = [for (var i = 0; i < positions.length; i++) i * 0.15];
    final shaders = List.generate(
      positions.length,
      (_) => _makeShader(shapeColor, backgroundColor, program),
    );

    return ShapeInstanceLayout._(positions, offsets, instanceScale, shaders);
  }

  /// Integrates positions forward using elapsed-seconds `currentTime`
  /// (matching ElapsedSecondsClock's .value) and reflects off the edges of
  /// `canvasSize`. No-op for static layouts. Called once per frame from the
  /// painter — you don't need to call this yourself.
  void advance(double currentTime, Size canvasSize) {
    final v = velocities;
    if (v == null) return;

    if (!_initialized) {
      _lastTime = currentTime;
      _initialized = true;
      return; // no prior sample yet, nothing to integrate on frame one
    }

    final dt = currentTime - _lastTime;
    _lastTime = currentTime;
    if (dt <= 0) return;

    // Keep the shape's visible edge (not just its center point) inside the
    // canvas — same margin logic as the draw-call bounding box.
    final marginX = min((instanceScale * 1.6) / canvasSize.width, 0.49);
    final marginY = min((instanceScale * 1.6) / canvasSize.height, 0.49);

    for (var i = 0; i < positions.length; i++) {
      var p = positions[i] + v[i] * dt;
      var vel = v[i];

      if (p.dx < marginX || p.dx > 1 - marginX) {
        vel = Offset(-vel.dx, vel.dy);
        p = Offset(p.dx.clamp(marginX, 1 - marginX), p.dy);
      }
      if (p.dy < marginY || p.dy > 1 - marginY) {
        vel = Offset(vel.dx, -vel.dy);
        p = Offset(p.dx, p.dy.clamp(marginY, 1 - marginY));
      }

      positions[i] = p;
      v[i] = vel;
    }
  }

  /// Creates a shader and writes its color uniforms once. Position/scale/
  /// time uniforms (indices 0-4) still get set every frame in paint(), but
  /// color (indices 5-11) never changes after this, so there's no reason to
  /// re-upload it 60 times a second.
  static ui.FragmentShader _makeShader(
    Color shapeColor,
    Color backgroundColor,
    ui.FragmentProgram program, {
    List<Color>? shapeColors,
    Random? random,
    ui.Image? logoImage,
  }) {
    final shader = program.fragmentShader();

    if (random != null && shapeColors != null && shapeColors.isNotEmpty) {
      List<Color> colors = shapeColors.toList();
      Random rando = random;
      Color randoColor = colors[rando.nextInt(colors.length)];
      shader
        ..setFloat(5, randoColor.r)
        ..setFloat(6, randoColor.g)
        ..setFloat(7, randoColor.b)
        ..setFloat(8, backgroundColor.r)
        ..setFloat(9, backgroundColor.g)
        ..setFloat(10, backgroundColor.b)
        ..setFloat(11, backgroundColor.a);
    } else {
      shader
        ..setFloat(5, shapeColor.r)
        ..setFloat(6, shapeColor.g)
        ..setFloat(7, shapeColor.b)
        ..setFloat(8, backgroundColor.r)
        ..setFloat(9, backgroundColor.g)
        ..setFloat(10, backgroundColor.b)
        ..setFloat(11, backgroundColor.a);
    }

    if (logoImage != null) {
      shader.setImageSampler(0, logoImage);
    }

    return shader;
  }

  /// Rasterizes arbitrary text into a ui.Image once — pass the result to
  /// .bouncing(logoImage: ...) along with logo_tint.frag's compiled program.
  /// Only the alpha channel matters; fill color here is irrelevant since the
  /// shader recolors it via uShapeColor.
  static Future<ui.Image> rasterizeTextLogo(
    String text, {
    TextStyle style = const TextStyle(
      fontSize: 64,
      fontWeight: FontWeight.w900,
      fontStyle: FontStyle.italic,
      color: Color(0xFFFFFFFF),
    ),
    double padding = 8,
  }) async {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    final size = Size(
      painter.width + padding * 2,
      painter.height + padding * 2,
    );
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Offset.zero & size);
    painter.paint(canvas, Offset(padding, padding));

    final picture = recorder.endRecording();
    return picture.toImage(size.width.ceil(), size.height.ceil());
  }

  /// Call when this layout is no longer needed (e.g. from State.dispose()).
  void dispose() {
    for (final s in shaders) {
      s.dispose();
    }
    logoImage?.dispose();
  }
}

class ShapeGridEffect extends StatelessWidget {
  const ShapeGridEffect({
    super.key,
    // required this.shader,
    required this.layout,
    required this.time, // e.g. an ElapsedSecondsClock — .value in seconds
  });

  // final ui.FragmentShader shader;
  final ShapeInstanceLayout layout;
  final ValueListenable<double> time;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _InstancedShapePainter(
        // shader: shader,
        layout: layout,
        time: time,
      ),
    );
  }
}

class _InstancedShapePainter extends CustomPainter {
  _InstancedShapePainter({
    // required this.shader,
    required this.layout,
    required this.time,
  }) : super(repaint: time); // <-- repaints every tick, no widget rebuild

  // final ui.FragmentShader shader;
  final ShapeInstanceLayout layout;
  final ValueListenable<double> time;

  // Reused across every instance draw — avoid allocating a new Paint per shape per frame.
  final Paint _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final t = time.value;
    layout.advance(t, size);

    final positions = layout.positions;
    final offsets = layout.timeOffsets;
    final scale = layout.instanceScale;

    for (var i = 0; i < positions.length; i++) {
      final shader = layout.shaders[i];
      final center = Offset(
        positions[i].dx * size.width,
        positions[i].dy * size.height,
      );

      shader
        ..setFloat(0, center.dx)
        ..setFloat(1, center.dy)
        ..setFloat(2, scale)
        ..setFloat(3, t)
        ..setFloat(4, offsets[i]);

      _paint.shader = shader;

      // Only rasterize the tiny bounding box this shape actually occupies —
      // this is the whole efficiency win versus a full-canvas draw.
      final r = scale * 1.6; // a bit of margin for antialiasing/glow
      canvas.drawRect(
        Rect.fromCenter(center: center, width: r * 2, height: r * 2),
        _paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _InstancedShapePainter oldDelegate) => false;
  // repaint is driven by the `repaint: time` listenable above, not by
  // widget-level diffing — shouldRepaint only matters for non-animation changes.
}
