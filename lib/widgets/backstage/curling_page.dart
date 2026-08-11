import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// ============================================================================
/// PageTextureCapture
/// ----------------------------------------------------------------------------
/// Renders `child` into an offscreen texture (a ui.Image) that the curl
/// shader can sample. Key gotcha: a widget only produces pixels once it's
/// actually been laid out AND painted at least one frame - so we can't just
/// build it and immediately call toImage(). We mount it for real (via a
/// RepaintBoundary + GlobalKey), positioned WAY off to the side inside a
/// Stack with clipBehavior: Clip.none so it still paints normally (just
/// outside the visible viewport), then grab the image after the first frame.
///
/// Positioning it off-screen (rather than e.g. wrapping in Opacity(0.0))
/// matters: Flutter's Opacity widget skips painting its child entirely when
/// opacity is 0, as a perf optimization - which means toImage() would
/// capture a blank frame. Off-screen positioning still paints normally.
/// ============================================================================
class PageTextureCapture extends StatefulWidget {
  final int pageCount;
  final Widget Function(BuildContext context, int index) pageBuilder;
  final double pageWidth;
  final double pageHeight;

  /// Called with a ready-to-use cache once all pages have been captured.
  final ValueChanged<PageImageCache> onReady;

  const PageTextureCapture({
    super.key,
    required this.pageCount,
    required this.pageBuilder,
    required this.pageWidth,
    required this.pageHeight,
    required this.onReady,
  });

  @override
  State<PageTextureCapture> createState() => _PageTextureCaptureState();
}

class _PageTextureCaptureState extends State<PageTextureCapture> {
  final Map<int, GlobalKey> _keys = {};

  @override
  void initState() {
    super.initState();
    debugPrint(
      'PageTextureCapture mounted, capturing ${widget.pageCount} pages',
    );
    for (int i = 0; i < widget.pageCount; i++) {
      _keys[i] = GlobalKey();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _captureAll());
  }

  Future<void> _captureAll() async {
    final cache = PageImageCache();
    for (final entry in _keys.entries) {
      final boundary =
          entry.value.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) continue;
      final image = await boundary.toImage(
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
      );
      cache._images[entry.key] = image;
    }
    widget.onReady(cache);
  }

  @override
  Widget build(BuildContext context) {
    // clipBehavior: Clip.none is the key line - lets off-screen children
    // still lay out and paint instead of being culled.
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final entry in _keys.entries)
          Positioned(
            left: -100000.0, // parked far outside any real viewport
            top: 0,
            width: widget.pageWidth,
            height: widget.pageHeight,
            child: RepaintBoundary(
              key: entry.value,
              child: widget.pageBuilder(context, entry.key),
            ),
          ),
      ],
    );
  }
}

/// Holds captured page textures, keyed by page index. Dispose when the book
/// widget is torn down to free GPU memory.
class PageImageCache {
  final Map<int, ui.Image> _images = {};

  ui.Image? operator [](int index) => _images[index];

  bool get isReady => _images.isNotEmpty;

  void dispose() {
    for (final img in _images.values) {
      img.dispose();
    }
    _images.clear();
  }
}

/// ============================================================================
/// CurlingPage
/// ----------------------------------------------------------------------------
/// Renders a single page with the cylindrical curl shader applied, driven by
/// `progress` (0.0 = flat/untouched, 1.0 = fully curled away) and `forward`
/// (which direction the curl sweeps).
/// ============================================================================
class CurlingPage extends StatelessWidget {
  final ui.Image pageImage;
  final double width;
  final double height;
  final double progress; // 0..1
  final bool forward;
  final ui.FragmentShader shader;

  /// Radius as a fraction of page width. ~0.15-0.25 looks like paper;
  /// smaller = tighter/crisper curl, larger = looser/floppier.
  final double radiusFraction;

  const CurlingPage({
    super.key,
    required this.pageImage,
    required this.width,
    required this.height,
    required this.progress,
    required this.forward,
    required this.shader,
    this.radiusFraction = 0.18,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _CurlPainter(
        pageImage: pageImage,
        progress: progress,
        forward: forward,
        shader: shader,
        radiusFraction: radiusFraction,
      ),
    );
  }
}

class _CurlPainter extends CustomPainter {
  final ui.Image pageImage;
  final double progress;
  final bool forward;
  final ui.FragmentShader shader;
  final double radiusFraction;

  _CurlPainter({
    required this.pageImage,
    required this.progress,
    required this.forward,
    required this.shader,
    required this.radiusFraction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width * radiusFraction;

    // Sweep curlX from "off the far edge" (fully flat) to "off the near
    // edge" (fully curled away), see the .frag file header for the math.
    final curlX = forward
        ? size.width * (1.0 - progress)
        : size.width * progress;
    final dir = forward ? 1.0 : -1.0;

    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, curlX)
      ..setFloat(3, radius)
      ..setFloat(4, dir)
      ..setImageSampler(0, pageImage);

    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _CurlPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.forward != forward ||
      oldDelegate.pageImage != pageImage;
}

/// ============================================================================
/// Loading the shader once, near the root of your app / book screen:
///
///   late final ui.FragmentShader curlShader;
///
///   Future<void> loadShader() async {
///     final program = await ui.FragmentProgram.fromAsset('shaders/page_curl.frag');
///     curlShader = program.fragmentShader();
///   }
///
/// pubspec.yaml:
///   flutter:
///     shaders:
///       - shaders/page_curl.frag
/// ============================================================================
