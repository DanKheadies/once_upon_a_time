#version 460 core
#include <flutter/runtime_effect.glsl>

// ============================================================================
// Cylindrical page-curl shader.
// ----------------------------------------------------------------------------
// Mental model: imagine the page rolling around an invisible cylinder of
// radius uRadius, whose axis sweeps across the page as uCurlX changes
// (driven by drag progress on the Dart side). Everything to the "flat" side
// of uCurlX is untouched. Everything past it gets mapped onto the curved
// surface of that cylinder: theta = how far around the cylinder a given
// point has rolled, in radians (0 = just starting to lift, pi/2 = the
// silhouette crest, i.e. the point where the paper is edge-on to the
// viewer).
//
// We only render the near (front-facing) half of the roll (theta 0..pi/2).
// Past the crest, the paper has rolled out of view around the far side of
// the cylinder — rather than modeling that occluded geometry, we simply
// don't draw anything there, which lets whatever's underneath (your static
// book-background image, or the next page) show through. Visually this
// reads as "the page is disappearing into the roll," which is correct.
// ============================================================================

uniform vec2 uSize;      // page size in logical pixels (width, height)
uniform float uCurlX;    // x position of the curl fold line (can go negative
                          // or beyond uSize.x as the fold sweeps through)
uniform float uRadius;   // cylinder radius - controls how "tight" the curl
                          // looks; try ~0.15-0.25 * uSize.x
uniform float uDir;      // +1.0 = curling toward the left (forward turn),
                          // -1.0 = curling toward the right (backward turn)
uniform sampler2D uPage; // captured page texture (your pixel-grid bg + text)

out vec4 fragColor;

const float PI = 3.14159265359;
const float HALF_PI = 1.57079632679;

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    float x = fragCoord.x;
    float y = fragCoord.y;

    // Signed distance from the fold line, in the direction of curling.
    // dx < 0 means "still flat, hasn't reached the fold yet."
    float dx = (x - uCurlX) * uDir;

    if (dx < 0.0) {
        // Flat region: sample the page texture directly, no distortion.
        vec2 uv = vec2(x, y) / uSize;
        vec4 color = texture(uPage, uv);

        // Soft contact shadow cast by the curling edge onto the flat page,
        // strongest right at the fold, fading out over ~uRadius*0.6.
        float shadowDist = -dx; // positive, distance behind the fold
        float shadow = smoothstep(uRadius * 0.6, 0.0, shadowDist) * 0.35;
        color.rgb *= (1.0 - shadow);

        fragColor = color;
        return;
    }

    float v = dx / uRadius;
    if (v > 1.0) {
        // Past the crest - rolled out of view. Nothing to draw here; the
        // layer beneath (book background / next page) shows through.
        fragColor = vec4(0.0);
        return;
    }

    // theta in [0, pi/2]: how far around the cylinder this fragment sits.
    float theta = asin(clamp(v, 0.0, 1.0));

    // Where on the ORIGINAL flat page this curled fragment's content came
    // from - arc length along the cylinder from the fold.
    float sourceX = uCurlX + uDir * uRadius * theta;

    // Guard against sampling past the actual page bounds (can happen right
    // at the very start/end of the sweep).
    if (sourceX < 0.0 || sourceX > uSize.x) {
        fragColor = vec4(0.0);
        return;
    }

    vec2 sourceUv = vec2(sourceX, y) / uSize;
    vec4 color = texture(uPage, sourceUv);

    // Shading across the curl: darken slightly as it rolls away from you,
    // with a bright rim/highlight right at the crest (theta -> pi/2), the
    // way light catches the curved edge of real paper.
    float shade = mix(1.0, 0.62, theta / HALF_PI);
    float rim = smoothstep(HALF_PI * 0.75, HALF_PI, theta) * 0.35;
    color.rgb = color.rgb * shade + rim;

    fragColor = color;
}
