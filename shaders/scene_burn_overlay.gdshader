shader_type canvas_item;

uniform float amount : hint_range(0.0, 1.0) = 0.0;
uniform float edge_width : hint_range(0.02, 0.45) = 0.18;
uniform float heat_distortion : hint_range(0.0, 0.08) = 0.012;
uniform float ember_strength : hint_range(0.0, 1.0) = 0.46;
uniform float char_strength : hint_range(0.0, 1.0) = 0.58;
uniform vec3 warm_tint : source_color = vec3(1.0, 0.54, 0.22);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(41.0, 289.0))) * 43758.5453123);
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
	float edge = min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y));
	float edge_mask = 1.0 - smoothstep(0.0, edge_width, edge);
	float ember_noise = noise(uv * vec2(18.0, 12.0) + vec2(t * 0.55, -t * 0.28));
	float heat_noise = noise(uv * vec2(9.0, 22.0) + vec2(-t * 0.24, t * 0.62));
	vec2 warped_uv = uv;
	warped_uv.x += (heat_noise - 0.5) * heat_distortion * edge_mask * amount;
	warped_uv.y += (ember_noise - 0.5) * heat_distortion * 0.75 * edge_mask * amount;

	vec4 base = texture(TEXTURE, clamp(warped_uv, vec2(0.0), vec2(1.0)));
	float ember_band = smoothstep(0.28, 0.92, ember_noise) * edge_mask;
	float core_glow = smoothstep(0.10, 0.48, edge_mask) * (0.55 + 0.45 * sin(t * 5.0 + uv.y * 16.0));
	vec3 charred = base.rgb * (1.0 - edge_mask * char_strength * amount);
	vec3 glow = warm_tint * ember_strength * amount * (ember_band * 0.85 + core_glow * 0.35);
	vec3 heated = charred + glow;
	heated.r += edge_mask * 0.08 * amount;
	heated.g += ember_band * 0.05 * amount;

	float overlay_alpha = clamp(amount * (0.18 + edge_mask * 0.82), 0.0, 1.0);
	COLOR = vec4(clamp(heated, 0.0, 1.0), base.a * overlay_alpha);
}
