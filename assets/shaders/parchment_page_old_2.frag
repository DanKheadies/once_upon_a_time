#version 460 core
#include <flutter/runtime_effect.glsl>

// ============================================================================
// Parchment page background - mesh gradient blended across 4 control
// colors, with an optional "pixel grid" mode that snaps the result to
// blocky cells and reduces the color range, matching a 15x19-ish pixel-art
// paper texture instead of a smooth gradient.
// ============================================================================

uniform vec2 uSize;
uniform vec4 uColorA;
uniform vec4 uColorB;
uniform vec4 uColorC;
uniform vec4 uColorD;
uniform float uSeed;

// --- New: grid/quantization controls ---
uniform float uCols;      // e.g. 15.0
uniform float uRows;      // e.g. 19.0
uniform float uLevels;    // posterize steps per channel, e.g. 8.0-12.0
uniform float uPixelate;  // 0.0 = smooth gradient, 1.0 = full blocky mode

// --- New: hue-lock controls ---
// Rather than hand-picking 4 colors that all happen to share a hue (easy
// to get wrong), we let uColorA-D be anything, then force the FINAL output
// back onto a single consistent hue family. This is what keeps the page
// looking like "one tan paper, lighter/darker in spots" instead of a quilt
// of green/pink/orange patches.
uniform float uTargetHue;      // 0-360, e.g. 42.0 for warm tan/khaki
uniform float uHueLock;        // 0.0 = don't touch hue, 1.0 = fully force it
uniform float uMaxSaturation;  // caps how colorful any block can get, e.g. 0.22

out vec4 fragColor;

// --- Standard RGB <-> HSL conversion, so we can manipulate hue/saturation
// directly instead of fighting with R/G/B values by hand. ---
vec3 rgb2hsl(vec3 c) {
    float maxC = max(c.r, max(c.g, c.b));
    float minC = min(c.r, min(c.g, c.b));
    float l = (maxC + minC) * 0.5;
    float delta = maxC - minC;

    float h = 0.0;
    float s = 0.0;
    if (delta > 0.0001) {
        s = delta / (1.0 - abs(2.0 * l - 1.0));
        if (maxC == c.r) {
            h = mod((c.g - c.b) / delta, 6.0);
        } else if (maxC == c.g) {
            h = (c.b - c.r) / delta + 2.0;
        } else {
            h = (c.r - c.g) / delta + 4.0;
        }
        h *= 60.0;
        if (h < 0.0) h += 360.0;
    }
    return vec3(h, s, l);
}

vec3 hsl2rgb(vec3 hsl) {
    float h = hsl.x;
    float s = hsl.y;
    float l = hsl.z;

    float c = (1.0 - abs(2.0 * l - 1.0)) * s;
    float x = c * (1.0 - abs(mod(h / 60.0, 2.0) - 1.0));
    float m = l - c * 0.5;

    vec3 rgb;
    if (h < 60.0)       rgb = vec3(c, x, 0.0);
    else if (h < 120.0) rgb = vec3(x, c, 0.0);
    else if (h < 180.0) rgb = vec3(0.0, c, x);
    else if (h < 240.0) rgb = vec3(0.0, x, c);
    else if (h < 300.0) rgb = vec3(x, 0.0, c);
    else                rgb = vec3(c, 0.0, x);
    return rgb + m;
}

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

// The mesh-gradient blend itself, factored out so it can be evaluated
// either per-fragment (smooth mode) or once per grid-cell-center
// (pixelated mode) using the same math either way.
vec3 meshBlend(vec2 uv, vec2 aspect) {
    vec2 p0 = vec2(0.15, 0.20) + 0.08 * vec2(noise(vec2(uSeed, 1.0)), noise(vec2(uSeed, 2.0)));
    vec2 p1 = vec2(0.85, 0.25) + 0.08 * vec2(noise(vec2(uSeed, 3.0)), noise(vec2(uSeed, 4.0)));
    vec2 p2 = vec2(0.25, 0.85) + 0.08 * vec2(noise(vec2(uSeed, 5.0)), noise(vec2(uSeed, 6.0)));
    vec2 p3 = vec2(0.80, 0.80) + 0.08 * vec2(noise(vec2(uSeed, 7.0)), noise(vec2(uSeed, 8.0)));

    float d0 = distance(uv * aspect, p0 * aspect);
    float d1 = distance(uv * aspect, p1 * aspect);
    float d2 = distance(uv * aspect, p2 * aspect);
    float d3 = distance(uv * aspect, p3 * aspect);

    float w0 = 1.0 / (d0 * d0 + 0.02);
    float w1 = 1.0 / (d1 * d1 + 0.02);
    float w2 = 1.0 / (d2 * d2 + 0.02);
    float w3 = 1.0 / (d3 * d3 + 0.02);
    float wSum = w0 + w1 + w2 + w3;

    return (uColorA.rgb * w0 + uColorB.rgb * w1 + uColorC.rgb * w2 + uColorD.rgb * w3) / wSum;
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / uSize;
    vec2 aspect = vec2(uSize.x / uSize.y, 1.0);

    // In pixelated mode, evaluate the gradient at the CENTER of whichever
    // grid cell this fragment falls in, rather than at the fragment's own
    // position. Every fragment in a cell then gets the identical color,
    // producing distinct blocks instead of a smooth blend.
    vec2 gridUv = uv;
    if (uPixelate > 0.5) {
        vec2 cell = floor(uv * vec2(uCols, uRows));
        gridUv = (cell + 0.5) / vec2(uCols, uRows);
    }

    vec3 color = meshBlend(gridUv, aspect);

    // Posterize: collapse each channel to a small number of steps. This is
    // what caps the effective palette down to roughly uLevels^3 possible
    // combinations - in practice, since the source colors are close warm
    // variants of one hue, this reads as "~8-12 similar parchment shades,"
    // matching a hand-tinted pixel-art paper texture.
    if (uPixelate > 0.5) {
        color = floor(color * uLevels) / uLevels;
    }

    // Grain and vignette still evaluate per-fragment (not per-cell) even
    // in pixelated mode - a uniform speckle/edge-darken layered over
    // blocky color reads as "aged pixel art," not just "a smooth
    // gradient with sharp edges."
    float grain = noise(fragCoord * 0.9 + uSeed) * 0.05;
    color -= grain;

    // float edgeDist = min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y));
    // float vignette = smoothstep(0.0, 0.35, edgeDist);
    // color = mix(uColorD.rgb * 0.7, color, vignette);

    // Hue-lock: whatever hue the blend/vignette/grain steps produced,
    // pull it toward uTargetHue and cap saturation. Lightness (hsl.z) is
    // left untouched, since that's what should vary block-to-block - hue
    // and saturation are what were causing the green/pink/orange patches.
    vec3 hsl = rgb2hsl(color);
    hsl.x = mix(hsl.x, uTargetHue, uHueLock);
    hsl.y = min(hsl.y, uMaxSaturation);
    color = hsl2rgb(hsl);

    fragColor = vec4(color, 1.0);
}
