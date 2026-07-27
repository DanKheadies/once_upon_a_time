import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:once_upon_a_time/barrel.dart';

/// Decodes an asset image straight to a dart:ui Image, bypassing the
/// Image *widget* entirely. This is the key function - notice there's no
/// `Image.asset(...)` anywhere here, only `dart:ui` codec calls, which is
/// what sidesteps the "two classes named Image" collision.
Future<ui.Image> loadUiImageFromAsset(String assetPath) async {
  final ByteData data = await rootBundle.load(assetPath);
  final ui.Codec codec = await ui.instantiateImageCodec(
    data.buffer.asUint8List(),
  );
  final ui.FrameInfo frame = await codec.getNextFrame();
  return frame.image; // this is a dart:ui.Image, exactly what CurlingPage wants
}

/// Throwaway isolated test screen: no SpinePageFlipper, no capture
/// pipeline, no gestures - just a slider driving the shader directly so you
/// can confirm the shader + CurlingPage work before trusting the plumbing
/// around them.
class CurlShaderTestScreen extends StatefulWidget {
  const CurlShaderTestScreen({super.key});

  @override
  State<CurlShaderTestScreen> createState() => _CurlShaderTestScreenState();
}

class _CurlShaderTestScreenState extends State<CurlShaderTestScreen> {
  ui.Image? _pageImage;
  ui.FragmentShader? _shader;
  double _progress = 0.0;
  bool _forward = true;
  String _status = 'Loading...';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      // Point this at any existing page-background asset you've already
      // declared in pubspec.yaml - your 15x19 pixel-grid art is perfect
      // for this test since you'll clearly SEE it warp if the curl works.
      final image = await loadUiImageFromAsset(
        'assets/images/storybook-cover.png',
      );
      final program = await ui.FragmentProgram.fromAsset(
        'assets/shaders/page_curl.frag',
      );
      setState(() {
        _pageImage = image;
        _shader = program.fragmentShader();
        _status = 'Loaded OK - drag the slider';
      });
    } catch (e) {
      setState(() => _status = 'FAILED: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Curl shader isolation test')),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Text(_status),
          const SizedBox(height: 12),
          if (_pageImage != null && _shader != null)
            Expanded(
              child: Center(
                child: CurlingPage(
                  pageImage: _pageImage!,
                  width: 360,
                  height: 480,
                  progress: _progress,
                  forward: _forward,
                  shader: _shader!,
                ),
              ),
            )
          else
            const Expanded(child: Center(child: CircularProgressIndicator())),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('forward'),
              Switch(
                value: _forward,
                onChanged: (v) => setState(() => _forward = v),
              ),
              const Text('backward'),
            ],
          ),
          Slider(
            value: _progress,
            onChanged: (v) => setState(() => _progress = v),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
