shader_type canvas_item;

uniform float amount : hint_range(0.0, 1.0) = 0.0;
uniform float noise_scale : hint_range(2.0, 40.0) = 12.0;
uniform float distortion_strength : hint_range(0.0, 0.08) = 0.018;
uniform float glow_strength : hint_range(0.0, 1.5) = 0.48;
uniform float desaturate_strength : hint_range(0.0, 1.0) = 0.32;
uniform vec3 glow_tint : source_color = vec3(0.84, 0.36, 1.0);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
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

void fragment() {
	vec2 uv = UV;
	float t = TIME;
	float warp_noise = noise(uv * (noise_scale * 0.7) + vec2(0.0, t * 0.34));
	float scan_noise = noise(uv * noise_scale + vec2(t * 0.85, -t * 0.48));
	float ripple = sin((uv.y + t * 0.42) * 24.0) * 0.5 + 0.5;
	vec2 warped_uv = uv;
	warped_uv.x += (warp_noise - 0.5) * distortion_strength * amount;
	warped_uv.y += (scan_noise - 0.5) * distortion_strength * 0.55 * amount;

	vec4 base = texture(TEXTURE, clamp(warped_uv, vec2(0.0), vec2(1.0)));
	float luma = dot(base.rgb, vec3(0.299, 0.587, 0.114));
	vec3 flattened = mix(base.rgb, vec3(luma), desaturate_strength * amount);
	vec3 glow = glow_tint * (0.22 + 0.78 * scan_noise) * glow_strength * amount;
	vec3 softened = mix(flattened, vec3(luma), 0.18 * amount);
	vec3 shifted = softened + glow;
	shifted += glow_tint * (ripple - 0.5) * 0.08 * amount;
	shifted = mix(shifted, vec3(luma), 0.08 * amount);

	COLOR = vec4(clamp(shifted, 0.0, 1.0), base.a * amount);
}
