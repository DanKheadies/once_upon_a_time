#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform vec4 uColorA; // e.g. warm cream
uniform vec4 uColorB; // e.g. golden tan
uniform vec4 uColorC; // e.g. burnt umber
uniform vec4 uColorD; // e.g. deep sepia (dominates near edges)
uniform float uSeed;

out vec4 fragColor;

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / uSize;

    // Four organic blob centers, nudged by uSeed so each reload varies —
    // same idea as your Dart-side seeded Random.
    vec2 p0 = vec2(0.15, 0.20) + 0.08 * vec2(noise(vec2(uSeed, 1.0)), noise(vec2(uSeed, 2.0)));
    vec2 p1 = vec2(0.85, 0.25) + 0.08 * vec2(noise(vec2(uSeed, 3.0)), noise(vec2(uSeed, 4.0)));
    vec2 p2 = vec2(0.25, 0.85) + 0.08 * vec2(noise(vec2(uSeed, 5.0)), noise(vec2(uSeed, 6.0)));
    vec2 p3 = vec2(0.80, 0.80) + 0.08 * vec2(noise(vec2(uSeed, 7.0)), noise(vec2(uSeed, 8.0)));

    // Aspect-correct so blobs stay round instead of stretching with the box.
    vec2 aspect = vec2(uSize.x / uSize.y, 1.0);
    float d0 = distance(uv * aspect, p0 * aspect);
    float d1 = distance(uv * aspect, p1 * aspect);
    float d2 = distance(uv * aspect, p2 * aspect);
    float d3 = distance(uv * aspect, p3 * aspect);

    // Inverse-distance weighting = a simple, cheap mesh-gradient blend.
    float w0 = 1.0 / (d0 * d0 + 0.02);
    float w1 = 1.0 / (d1 * d1 + 0.02);
    float w2 = 1.0 / (d2 * d2 + 0.02);
    float w3 = 1.0 / (d3 * d3 + 0.02);
    float wSum = w0 + w1 + w2 + w3;

    vec3 color = (uColorA.rgb * w0 + uColorB.rgb * w1 + uColorC.rgb * w2 + uColorD.rgb * w3) / wSum;

    // Paper grain.
    float grain = noise(fragCoord * 0.9 + uSeed) * 0.06;
    color -= grain;

    // Edge burn: darken toward the nearest edge, works at any aspect ratio
    // (this replaces the RadialGradient vignette problem entirely).
    float edgeDist = min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y));
    float vignette = smoothstep(0.0, 0.35, edgeDist);
    color = mix(uColorD.rgb * 0.7, color, vignette);

    fragColor = vec4(color, 1.0);
}