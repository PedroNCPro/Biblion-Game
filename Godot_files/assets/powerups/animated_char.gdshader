shader_type canvas_item;

void fragment() {
	vec2 uv = 2.0 * UV - 1.0;
	COLOR = vec4(vec3(1.0), step(0.4, 1. - dot(uv, uv)));
}
