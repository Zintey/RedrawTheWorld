shader_type canvas_item;

uniform sampler2D noise_tex;
uniform vec3 color : source_color;

uniform float ring1 = 0.88;
uniform float ring2 = 0.9;

uniform float noise_strength = 0.02;
uniform float noise_scale = 4.0;

uniform float breath_speed = 2.0;
uniform float breath_strength = 0.015;

void fragment() {

	vec2 uv = UV * 2.0 - 1.0;
	float d = length(uv);

	float noise = texture(noise_tex, UV * noise_scale).r;
	d += (noise - 0.5) * noise_strength;

	float breath = sin(TIME * breath_speed) * breath_strength;

	float inner = ring1 + breath;
	float outer = ring2 + breath;

	float ring = smoothstep(inner, inner + 0.005, d)
			   - smoothstep(outer, outer + 0.005, d);

	COLOR = vec4(vec3(ring) * color, ring);
}