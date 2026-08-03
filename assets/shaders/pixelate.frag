#version 460 core
precision highp float;
#include <flutter/runtime_effect.glsl>

// No explicit layout(location=N) here — when omitted, impellerc assigns
// locations automatically in declaration order, which lines up with the
// Dart-side setFloat/setImageSampler indices used below:
//   uDownsample -> floats 0,1
//   uSize       -> floats 2,3
//   uTexture    -> sampler index 0
uniform vec2 uDownsample; // how many "pixels" the effect divides the image into (x, y)
uniform vec2 uSize;       // actual output size in px
uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
    fragColor = texture(
        uTexture,
        round((FlutterFragCoord().xy / uSize) * uDownsample) / uDownsample
    );
}
