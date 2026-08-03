#version 460 core
#include <flutter/runtime_effect.glsl>

// Same uniform index layout as instanced_shape_morph.frag (uTime/uTimeOffset
// unused here) so both shaders can be driven by the same Dart-side code path.
layout(location = 0) uniform vec2 uCenter;      // instance center, absolute device px
layout(location = 1) uniform float uScale;      // instance "radius" in px
layout(location = 2) uniform float uTime;       // unused
layout(location = 3) uniform float uTimeOffset; // unused
layout(location = 4) uniform vec3 uShapeColor;
layout(location = 5) uniform vec4 uBgColor;

// Samplers still need a GLOBALLY unique `location` value — it's one shared
// namespace across every uniform in the shader, not a separate space per
// resource type. The six uniforms above used locations 0-5, so this is 6.
layout(location = 6) uniform sampler2D uLogoTex;

out vec4 fragColor;

void main() {
    vec2 p = (FlutterFragCoord().xy - uCenter) / uScale; // ~-1.6..1.6, matches the draw rect's margin
    vec2 uv = clamp(p / 1.6 * 0.5 + 0.5, 0.0, 1.0);

    // The rasterized text image is transparent outside the glyphs, opaque
    // inside — alpha IS the coverage mask, same role sdBox/sdRing played before.
    float coverage = texture(uLogoTex, uv).a;

    vec3 color = mix(uBgColor.rgb, uShapeColor, coverage);
    float alpha = mix(uBgColor.a, 1.0, coverage);
    fragColor = vec4(color * alpha, alpha); // premultiplied
}
