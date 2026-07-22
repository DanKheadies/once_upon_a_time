#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform vec4 uColor;

out vec4 FragColor;

void main() {
    vec2 pixel = FlutterFragCoord() / uSize;

    vec4 white = vec4(1.0);

    vec4 colorWithAlpha = vec4(uColor.rgb * uColor.a, uColor.a);

    FragColor = mix(colorWithAlpha, white, pixel.x);
}
