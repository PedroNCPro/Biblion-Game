shader_type canvas_item;

uniform int which;
uniform vec3 clr;

mat2 rot2D(float theta)
{
    return mat2(vec2(cos(theta), sin(theta)), vec2(-sin(theta), cos(theta)));
}

float sdSegment( in vec2 p, in vec2 a, in vec2 b )
{
    vec2 pa = p-a, ba = b-a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h );
}

float sdf(vec2 uv)
{
    switch(which)
    {
        case 1:
            float hole = 0.275;
            vec2 uv2 = rot2D(3.1416 / 4.) * uv;
             //uv2 = uv;
            const float pn = 8.0;
            float border = 0.05;
            float sz = 0.35;
            return 1. - smoothstep(sz - border, sz, abs(pow(pow(uv2.x, pn) + pow(uv2.y, pn), 1. / pn) - hole) + hole);
        case 2:
            float border = 0.005;
            float sz = 0.011;
            return 1. - smoothstep(sz - border, sz, 
                min(sdSegment(rot2D(2. * 3.1416 / 4.) * 0.15 * uv, vec2(-0.04, 0.), vec2(0.04, 0.)),
                    sdSegment(                          0.15 * uv, vec2(-0.04, 0.), vec2(0.04, 0.))));
        case 3:
            float border = 0.005;
            float sz = 0.015;
            return 1. - smoothstep(sz - border, sz, sdSegment(rot2D(3.1416 / 4.) * 0.15 * uv, vec2(-0.05, 0.), vec2(0.05, 0.)));
        case 4:
            float border = 0.005;
            float sz = 0.015;
            return 1. - smoothstep(sz - border, sz, sdSegment(rot2D(3. * 3.1416 / 4.) * 0.15 * uv, vec2(-0.05, 0.), vec2(0.05, 0.)));
        default:
            return 0.0;
    }
}

vec4 combine(vec4 a, vec4 b)
{
	return vec4(mix(a.rgb, b.rgb, b.a), a.a + b.a);
}

void fragment()
{
    float freq = 2.;
    vec2 uv2 = fract(freq * rot2D(3.1416 / 4.) * (2.0 * (UV - 0.05 * TIME) - 1.0));

    vec2 uv3 = 2.0 * UV - 1.0;
    float pn = 8.0;
    float d = pow(pow(uv3.x, pn) + pow(uv3.y, pn), 1. / pn);
    float sz = 0.95 + 0.017 * sin(7. * atan(uv3.y, uv3.x) + 1.13 * TIME);
    float border = 0.025;
    float contour = smoothstep(sz - 0.05, sz, d) * (1. - smoothstep(sz - 0.05, sz + 0.15, d));

    COLOR.rgb = mix(clr, 0.6 * clr, sdf(uv2 - 0.5));
    COLOR.a = 1. - smoothstep(sz, sz + 0.04, d);
    //COLOR.rgb *= pow(1. - contour, 4.0);
}