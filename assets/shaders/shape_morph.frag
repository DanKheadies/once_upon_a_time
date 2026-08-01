#version 460 core
#include <flutter/runtime_effect.glsl>

// uniforms (set these from Dart via FragmentShader.setFloat)
layout(location = 0) uniform vec2 uSize;   // canvas size in px
layout(location = 1) uniform float uTime;  // seconds, monotonically increasing

out vec4 fragColor;

// ---------- SDFs ----------

// solid disc
float sdCircle(vec2 p, float r) {
    return length(p) - r;
}

// ring (donut cross-section): distance to the boundary band of a circle
float sdRing(vec2 p, float r, float thickness) {
    return abs(length(p) - r) - thickness;
}

// axis-aligned box, b = half-extents
float sdBox(vec2 p, vec2 b) {
    vec2 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

// ---------- easing ----------

float easeInOut(float t) {
    return t * t * (3.0 - 2.0 * t); // smoothstep-style ease, no extra args needed
}

void main() {
    vec2 uv = (FlutterFragCoord().xy - 0.5 * uSize) / min(uSize.x, uSize.y);
    // uv is now centered at (0,0), roughly in [-0.5, 0.5]

    // --- cycle timing ---
    // 4 stages, each STAGE_LEN seconds long:
    //   0: donut -> square
    //   1: square -> bar
    //   2: bar holds shape, pulses/translates up and down
    //   3: bar -> donut
    const float STAGE_LEN = 2.0;
    float cycle = mod(uTime, STAGE_LEN * 4.0);
    int stage = int(floor(cycle / STAGE_LEN));
    float local = fract(cycle / STAGE_LEN); // 0..1 progress within the stage
    float t = easeInOut(local);

    // --- shape params ---
    float donutR = 0.28;
    float donutThickness = 0.07;
    vec2 squareHalf = vec2(0.22);

    // bar geometry: width stays narrow, height oscillates for the "up and down" feel
    float barWidth = 0.10;
    float barHeightBase = 0.34;

    float d; // final signed distance
    vec2 p = uv;

    if (stage == 0) {
        // donut -> square
        float dDonut = sdRing(p, donutR, donutThickness);
        float dSquare = sdBox(p, squareHalf);
        d = mix(dDonut, dSquare, t);

    } else if (stage == 1) {
        // square -> bar (bar starts at rest, no bounce yet)
        float dSquare = sdBox(p, squareHalf);
        float dBar = sdBox(p, vec2(barWidth, barHeightBase));
        d = mix(dSquare, dBar, t);

    } else if (stage == 2) {
        // bar shape holds, but pulses height and slides up/down
        float wave = sin(local * 3.14159265 * 2.0); // -1..1 over this stage
        float height = barHeightBase + 0.10 * wave;
        float yOffset = 0.12 * wave;
        vec2 pBar = p - vec2(0.0, yOffset);
        d = sdBox(pBar, vec2(barWidth, height));

    } else {
        // bar -> donut
        float dBar = sdBox(p, vec2(barWidth, barHeightBase));
        float dDonut = sdRing(p, donutR, donutThickness);
        d = mix(dBar, dDonut, t);
    }

    // antialiased fill: fwidth() isn't available in SkSL runtime effects, so
    // instead of asking the GPU for screen-space derivatives, compute the
    // edge width manually — uv is already divided by min(uSize.x, uSize.y),
    // so 1 real pixel there is ~1 / min(uSize.x, uSize.y).
    float edge = 1.5 / min(uSize.x, uSize.y);
    float shape = 1.0 - smoothstep(-edge, edge, d);

    vec3 shapeColor = vec3(0.95, 0.55, 0.15); // warm accent, swap for your palette
    vec3 bg = vec3(0.06, 0.06, 0.08);

    vec3 color = mix(bg, shapeColor, shape);
    fragColor = vec4(color, 1.0);
}
