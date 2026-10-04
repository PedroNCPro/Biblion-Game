shader_type canvas_item;

uniform sampler2D fire_grad;
uniform sampler2D air_grad;
uniform sampler2D lightning_grad;
uniform sampler2D water_grad;
uniform sampler2D vegetal_grad;
uniform sampler2D earth_grad;
uniform sampler2D fire_noise : repeat_enable;
uniform sampler2D air_noise : repeat_enable;
uniform sampler2D earth_noise : repeat_enable;

uniform float lerping;
uniform int base_elem;
uniform int target_elem;

vec4 fire(vec2 uv)
{
	uv.y += 0.03;
	float n1 = texture(fire_noise, uv * vec2(0.6, 1.0) + vec2(0.144, 0.191) * TIME).r;
	float n2 = texture(fire_noise, uv * vec2(0.4, 1.0) + vec2(0.123, -0.187) * TIME).r;
	float n = n1 * n2;
	vec2 uv2 = uv * 2.0 - 1.0;
	uv2.y *= 0.87;
	float pn = 8.0;
	float border = smoothstep(0.84, 0.97, pow(pow(uv2.x * 1.06 + 0.2 * (abs(1.3 * n1 - 0.5)), pn) + pow(uv2.y * 1.06 + 0.2 * (abs(1.3 * n2 - 0.5)), pn), 1.0 / pn));
	vec4 clr;
	clr.rgb = texture(fire_grad, vec2(n, 0.0)).rgb;
	clr.a = (1.0 - border) * (1. - smoothstep(0.35, 0.8, -uv2.y + 0.1 * sin(30.0 * uv.x * n1 + TIME)));
	clr.a *= 1. - smoothstep(0.9, 1.0, 1. - uv.y);
	return clr;
}

vec4 lightning(vec2 uv)
{
	uv.y -= 0.01;
	vec2 uv2 = 2.0 * uv - 1.0;
	uv2 *= 1.1;
	float t = atan(uv2.y, uv2.x) + 0.0 * TIME;
	float n1 = texture(fire_noise, vec2(t * 0.6 + 0.23, 0.3)).r;
	float n2 = texture(fire_noise, vec2(t * 0.53 - 0.31, 0.4)).r;
	float n = n1 * n2;
	
	vec4 clr = vec4(1.0);
	clr.rgb = texture(lightning_grad, vec2(n, 0.0)).rgb;
	float pn = 8.0;
	float bb = pow(pow(uv2.x, pn) + pow(uv2.y, pn), 1.0 / pn) + 0.1 * sin(10.0 * t + 2.2 * TIME) * (1.7 * pow(cos(3.0 * sin(1.9 * TIME) +n1),8.0)+n2)  * n1;
	float bc = pow(pow(uv2.x, pn) + pow(uv2.y, pn), 1.0 / pn) + 0.1 * cos(12.0 * t - 2.3 * TIME) * (1.8 * pow(sin(3.0 * cos(2.86 * TIME)+n2),8.0)+n1) * n2;
	//bb = 1.04 * bb + 0.05 * sin(TIME + phi);
	clr.a = 0.5*(pow(cos(3.0 * sin(1.9 * TIME) +n1),8.0)+ pow(cos(3.0 * sin(2.86 * TIME) +n2),8.0)) * max(pow(smoothstep(0.97, 0.92, bb) * smoothstep(0.87, 0.96, bb), 0.5), pow(smoothstep(0.97, 0.92, bc) * smoothstep(0.87, 0.96, bc), 0.5));
	return clr;
}

vec4 combine(vec4 a, vec4 b)
{
	return vec4(mix(a.rgb, b.rgb, b.a), a.a + b.a);
}

vec4 air(vec2 uv)
{
	vec2 uv2 = 2.0 * uv - 1.0;
	float n1 = texture(air_noise, uv * vec2(0.8, 1.0) + 0.2 * vec2(0.144, 0.191) * TIME).r;
	float n2 = texture(air_noise, uv * vec2(0.6, 1.0) + 0.21 * vec2(0.123, -0.187) * TIME).r;
	float n = n1 * n2 + 0.2 * (1.0 - uv.y);
	vec4 clr;
	clr.rgb = texture(air_grad, vec2(n, 0.0)).rgb;
	float pn = 8.0;
	clr.a = 1.0 - smoothstep(0.84, 0.92, pow(pow(-0.05 + uv2.x * 1.06 + 0.2 * (abs(1.3 * n1 - 0.5)), pn) + pow(-0.08 + uv2.y * 1.06 + 0.2 * (abs(1.3 * n2 - 0.5)), pn), 1.0 / pn));
	return combine(clr, lightning(uv));
}

vec4 water(vec2 uv)
{
	vec2 uv2 = 2.0 * uv - 1.0;
	float n1 = texture(air_noise, uv * vec2(0.8, 1.0) + 0.5 * vec2(0.144, 0.191) * TIME).r;
	float n2 = texture(air_noise, uv * vec2(0.6, 1.0) + 0.7 * vec2(0.123, -0.187) * TIME).r;
	float n = 0.7 *n1*n2+0.3*smoothstep(0.465, 0.475, 1.0 - (0.5 * (n1 + n2))) * smoothstep(0.5, 0.51, 0.5 * (n1 + n2));
	
	vec4 clr;
	clr.rgb = texture(water_grad, vec2(n, 0.0)).rgb;
	float pn = 8.0;
	clr.a = 1.0 - smoothstep(0.87, 0.9, pow(pow(0.03 + uv2.x * 1.06 + 0.06 * (abs(1.3 * n1 - 0.5)), pn) + pow(-0.04 + uv2.y * 1.06 + 0.06 * (abs(1.3 * n2 - 0.5)), pn), 1.0 / pn));
	return clr;
}

vec4 vegetation(vec2 uv)
{
	uv.y -= 0.005;
	vec2 uv2 = 2.0 * uv - 1.0;
	uv2 *= 1.1;
	float t = atan(uv2.y, uv2.x) + (0.1 + 0.28 * TIME);
	float n = sin(t);
	
	float n2 = texture(fire_noise, vec2(uv) * vec2(1.6, 1.9) + vec2(0.1)).r;
	float laby = smoothstep(0.46, 0.475, 1.0 - n2) * smoothstep(0.5, 0.515, n2);
	vec4 clr = vec4(1.0);
	clr.rgb = texture(vegetal_grad, vec2(laby, 0.0)).rgb;
	float pn = 8.0;
	float bb = pow(pow(uv2.x, pn) + pow(uv2.y, pn), 1.0 / pn) + 0.03 * sin(10.0 * t);
	//uv2 *= 2.0;
	//bb = (pow(pow(uv2.x, pn) + pow(uv2.y, pn), 1.0 / pn) + 0.03 * sin(10.0 * t));

	clr.a = pow(smoothstep(0.99, 0.94, bb) * smoothstep(0.88, 0.94, bb), 0.5 + 0.4 * (sin(TIME / 0.5)));
	//clr.a = 1.0;
	return clr;
}

vec4 earth(vec2 uv)
{
	uv += vec2(0.01, -0.01);
	vec2 uv2 = 2.0 * uv - 1.0;
	uv2 *= 1.15;
	float n = texture(earth_noise, uv).r;
	vec4 clr;
	clr.rgb = texture(earth_grad, vec2(n, 0.0)).rgb;
	clr.a = 1.0 - smoothstep(0.91, 0.97, max(abs(uv2.x), abs(uv2.y)));
	return combine(clr, vegetation(uv));
}

vec4 normal(vec2 uv)
{
	uv += vec2(0.012, -0.02);
	vec2 uv2 = 2.0 * uv - 1.0;
	return vec4(vec3(1.), 1.0 - smoothstep(0.82, 0.83, max(abs(uv2.x), abs(uv2.y))));
}

vec4 choose(vec2 uv, int which)
{
	switch(which)
	{
		case 1:
			return fire(uv);
		case 2:
			return water(uv);
		case 3:
			return air(uv);
		case 4:
			return earth(uv);
		default:
			return normal(uv);
	}
}

void fragment()
{	
	COLOR = lerping > 1e-4 ? 
			mix(choose(UV, base_elem), choose(UV, target_elem), lerping) 
			: choose(UV, base_elem);	
}

