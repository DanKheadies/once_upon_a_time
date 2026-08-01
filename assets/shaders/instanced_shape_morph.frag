#version 460 core
#include <flutter/runtime_effect.glsl>

// uniforms — set fresh before EACH small drawRect() call
layout(location = 0) uniform vec2 uCenter;     // this instance's center, in absolute device px
layout(location = 1) uniform float uScale;     // this instance's "radius" in px (half-extent)
layout(location = 2) uniform float uTime;      // global elapsed seconds
layout(location = 3) uniform float uTimeOffset; // per-instance phase offset, so they desync
layout(location = 4) uniform vec3 uShapeColor;  // rgb, 0..1
layout(location = 5) uniform vec4 uBgColor;     // rgb + alpha, 0..1 — alpha 0 = fully transparent

out vec4 fragColor;

// ---------- SDFs ----------
float sdRing(vec2 p, float r, float thickness) {
    return abs(length(p) - r) - thickness;
}
float sdBox(vec2 p, vec2 b) {
    vec2 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}
float easeInOut(float t) {
    return t * t * (3.0 - 2.0 * t);
}

void main() {
    // NOTE: FlutterFragCoord() is in absolute device pixels, same as gl_FragCoord —
    // it is NOT affected by canvas.translate(). That's why we pass uCenter explicitly
    // instead of assuming the shape sits at the middle of a local 0..size rect.
    vec2 p = (FlutterFragCoord().xy - uCenter) / uScale;

    float t = uTime + uTimeOffset;
    const float STAGE_LEN = 2.0;
    float cycle = mod(t, STAGE_LEN * 4.0);
    int stage = int(floor(cycle / STAGE_LEN));
    float local = fract(cycle / STAGE_LEN);
    float ease = easeInOut(local);

    float donutR = 0.55, donutThickness = 0.16;
    vec2 squareHalf = vec2(0.45);
    float barWidth = 0.20, barHeightBase = 0.65;

    float d;
    if (stage == 0) {
        d = mix(sdRing(p, donutR, donutThickness), sdBox(p, squareHalf), ease);
    } else if (stage == 1) {
        d = mix(sdBox(p, squareHalf), sdBox(p, vec2(barWidth, barHeightBase)), ease);
    } else if (stage == 2) {
        float wave = sin(local * 3.14159265 * 2.0);
        float height = barHeightBase + 0.18 * wave;
        vec2 pBar = p - vec2(0.0, 0.20 * wave);
        d = sdBox(pBar, vec2(barWidth, height));
    } else {
        d = mix(sdBox(p, vec2(barWidth, barHeightBase)), sdRing(p, donutR, donutThickness), ease);
    }

    // fwidth()/dFdx()/dFdy() are NOT available in SkSL runtime effects — Skia
    // needs these shaders to also run on backends without screen-space
    // derivatives (e.g. CPU raster), so the whole derivative family is
    // excluded. We fake a screen-consistent edge width manually instead:
    // p is already divided by uScale, so 1 real pixel there is ~1/uScale.
    float edge = 1.5 / uScale;
    float coverage = 1.0 - smoothstep(-edge, edge, d);

    // "over" composite: shape color where coverage is high, background where
    // it's low, smoothly blended at the antialiased edge in between.
    vec3 color = mix(uBgColor.rgb, uShapeColor, coverage);
    float alpha = mix(uBgColor.a, 1.0, coverage);

    // Skia/Impeller expect PREMULTIPLIED alpha from runtime-effect shaders —
    // rgb must already be scaled by alpha, or transparent edges render too
    // bright/dark instead of cleanly fading into whatever's behind them.
    fragColor = vec4(color * alpha, alpha);
}
