shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform float max_blur_amount : hint_range(0.0, 5.0) = 2.5;
uniform vec2 center = vec2(0.5, 0.5);
uniform float vignette_radius : hint_range(0.0, 1.0) = 0.2; 
uniform float vignette_softness : hint_range(0.0, 1.0) = 0.5; 

void fragment() {
    float dist = distance(UV, center);
    float blur_factor = smoothstep(vignette_radius, vignette_radius + vignette_softness, dist);
    float current_blur = blur_factor * max_blur_amount;
    COLOR = textureLod(screen_texture, SCREEN_UV, current_blur);
}