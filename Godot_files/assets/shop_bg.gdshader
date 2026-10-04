shader_type canvas_item;

uniform vec3 clr;

void fragment()
{
    float freq = 6.;
    vec2 uv2 = fract(freq * (2.0 * (UV / vec2(1213./687., 1.) - 0.025 * TIME) - 1.0));
	uv2 -= 0.5;

    COLOR.rgb = mix(clr, 0.9 * clr, 1. - smoothstep(0.2, 0.25, abs(uv2.x) + abs(uv2.y)));
}