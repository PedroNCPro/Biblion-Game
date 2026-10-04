shader_type canvas_item;

uniform vec2 center = vec2(0.5, 0.5);
uniform float vignette_radius : hint_range(0.0, 1.0) = 0.2;
uniform float vignette_softness : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    float dist = distance(UV, center);
    float alpha_factor = 1.0 - smoothstep(vignette_radius, vignette_radius + vignette_softness, dist);
    COLOR = vec4(tex_color.rgb, tex_color.a * alpha_factor);
}