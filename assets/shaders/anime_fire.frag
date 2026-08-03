shader_type canvas_item;

// enable/disable custom (low) fps
#define USE_CUSTOM_FPS 1

// enable/disalbe distortion exclusion mask
#define USE_DISTORTION_EXCLUSION_MASK 1

uniform float speed = 0.5;
uniform float normal_scl_out = 1.5;
uniform float normal_scl_in = 2.0;
uniform float noise_scl_out = 0.4;
uniform float noise_scl_in = 0.2;
uniform float distortion_scl_out = 0.10;
uniform float distortion_scl_in = 0.08;
#if USE_DISTORTION_EXCLUSION_MASK
uniform float mask_force : hint_range(0.0, 1.0) = 0.6;
#endif
#if USE_CUSTOM_FPS
uniform float fps = 12.0;
#endif

uniform sampler2D draw_tex;
uniform sampler2D normal_tex : repeat_enable;
uniform sampler2D noise_tex : repeat_enable;
#if USE_DISTORTION_EXCLUSION_MASK
uniform sampler2D mask_tex;
#endif

uniform vec4 color_out_a : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 color_out_b : source_color = vec4(1.0, 0.25, 0.0, 1.0);
uniform vec4 color_in_a : source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform vec4 color_in_b : source_color = vec4(1.0, 1.0, 0.5, 1.0);

void fragment() {
	// get UVs
	vec2 uv_out = UV;
	vec2 uv_in = UV;
	
#if USE_CUSTOM_FPS	
	float t = floor(TIME * fps) / fps;
#else
	float t = TIME;
#endif	
	
	uv_out.y += t * speed;
	uv_in.y += (0.5 + t) * speed;

	// sample noise
	vec2 noi_out = (texture(noise_tex, uv_out * noise_scl_out).rg * 2.0) - 1.0;
	vec2 noi_in = (texture(noise_tex, uv_in * noise_scl_in).rg * 2.0) - 1.0;

	// sample normal map
	vec4 nrm_out = texture(normal_tex, (uv_out * normal_scl_out) + noi_out.xy);
	vec4 nrm_in = texture(normal_tex, (uv_in * normal_scl_in) + noi_in.xy);
	nrm_out.xyz = nrm_out.xyz * 2.0 - 1.0;
	nrm_in.xyz = nrm_in.xyz * 2.0 - 1.0;
	
	// compute distorted UVs
	vec2 distorted_uv_out = UV + vec2(nrm_out.x, -nrm_out.y) * distortion_scl_out;
	vec2 distorted_uv_in = UV + vec2(nrm_in.x, -nrm_in.y) * distortion_scl_in;
	
#if USE_DISTORTION_EXCLUSION_MASK	
	// get distortion exclusion mask
	float msk = texture(mask_tex, UV).r * mask_force;
	
	// compute final distortion UVs
	vec2 final_uv_out = mix(distorted_uv_out, UV, msk);
	vec2 final_uv_in = mix(distorted_uv_in, UV, msk);
#else
	vec2 final_uv_out = distorted_uv_out;
	vec2 final_uv_in = distorted_uv_in;
#endif	

	// get inside and outside masks
	float outside = texture(draw_tex, final_uv_out).r;
	float inside = texture(draw_tex, final_uv_in).g;
	
	// compute final color
	vec4 final_color = outside * mix(color_out_a, color_out_b, UV.y);
	final_color = mix(final_color, mix(color_in_a, color_in_b, UV.y), inside);
			
	COLOR = final_color;
}