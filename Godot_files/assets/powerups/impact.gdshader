shader_type canvas_item;

uniform int which_elem;
uniform float t;
uniform sampler2D lightning_grad;
uniform sampler2D fire_grad;
uniform sampler2D water_grad;
uniform sampler2D leaf_grad;
uniform sampler2D lightning_noise : repeat_enable;
uniform sampler2D fire_noise : repeat_enable;
uniform sampler2D water_noise : repeat_enable;

uniform float t_reaction;
uniform int which_a;
uniform int which_b;

vec4 lightning(vec2 uv)
{
	float t1 = 16.0 * min(0.25 * 0.25, t * t);
	float t2 = 4.0 * (max(0.75 * 0.75, t * t) - (0.75 * 0.75));

	float border = (1.0 - smoothstep(0.0 + 0.5 * t1, 0.1 + 0.5 * t1, uv.y));
	border *= smoothstep(0.0 + 0.5 * t2, 0.1 + 0.5 * t2, uv.y);
	if(t < 1e-4 || t > (1. - 1e-4)) border = 0.;
	uv.y -= 1.54 * t;
	uv.y *= 0.1;
	float flux = 2.0 * texture(lightning_noise, vec2(0.3, uv.y)).r - 1.0;
	float xos = 0.5 + 0.06 * flux;
	float d = min(1., 0.008 / abs(xos - (0.25 + 0.5 * (uv.x + 0.00 * sin(100.0 * uv.y)))));
	
	vec4 clr = vec4(1.0);
	clr.rgb = texture(lightning_grad, vec2(0.4 * (sqrt(0.9 * d)), 0.0)).rgb;
	clr.a = smoothstep(0.0, 1.0, d) * border;
	return clr;
}

vec4 fireball(vec2 uv)
{
	vec2 uv3 = uv;
	uv.y += 0.1 + 0.5 * (1. - 4.0 * min(0.5 * 0.5, t * t));
	float t3 = 4.0 * (max(0.4 * 0.4, t * t) - (0.4 * 0.4));
	uv.y -= 0.04;
	float n1 = texture(fire_noise, uv * vec2(0.6, 1.0) + vec2(0.144, 0.191) * TIME).r;
	float n2 = texture(fire_noise, uv * vec2(0.4, 1.0) + vec2(0.123, -0.187) * TIME).r;
	float n = n1 * n2;
	vec2 uv2 = (2.6 - 0.45 * t3) * (uv * 2.0 - 1.0);
	vec4 clr;
	clr.rgb = texture(fire_grad, vec2(n, 0.0)).rgb;
	float up = 0.5 * (1. - smoothstep(-0.8, 0.4, uv2.y));
	float ra = 0.5 + up;
	clr.a = (1. - smoothstep(ra, ra + 0.1, dot(uv2 + (0.3 + 0.7 * up + 0.4 * t3) 
		* (n1 - 0.5), uv2 + 0.3 * (n2 - 0.5)))) 
		* (1. - smoothstep(0.35, 0.8, -uv2.y + 0.1 * sin(30.0 * uv.x * n1 + TIME)));
	
	float t2 = 4.0 * (max(0.75 * 0.75, t * t) - (0.75 * 0.75));
	clr.a *= smoothstep(0.0, 0.1, uv3.y) * smoothstep(0.0 + 0.5 * t2, 0.1 + 0.5 * t2, uv3.y);
	if(t < 1e-4 || t > (1. - 1e-4)) clr.a = 0.;
	return clr;
}

vec4 droplet(vec2 uv)
{
	vec2 uv3 = uv;
	uv.y += 0.1 + 0.5 * (1. - 4.0 * min(0.5 * 0.5, t * t));
	float t3 = 4.0 * (max(0.4 * 0.4, t * t) - (0.4 * 0.4));
	uv.y -= 0.04;

	vec2 uv2 = 1.85 * (2.0 * uv - 1.0);
	float n1 = texture(water_noise, uv * vec2(0.8, 1.0) + 0.5 * vec2(0.144, 0.191) * TIME).r;
	float n2 = texture(water_noise, uv * vec2(0.6, 1.0) + 0.7 * vec2(0.123, -0.187) * TIME).r;
	float n = 0.7 *n1*n2+0.3*smoothstep(0.465, 0.475, 1.0 - (0.5 * (n1 + n2))) * smoothstep(0.5, 0.51, 0.5 * (n1 + n2));
	
	vec2 uv4 = uv2 * vec2(1., 0.65);
	vec4 clr;
	clr.rgb = texture(water_grad, vec2(n, 0.0)).rgb;
	float ra = 0.5 - 0.5 * (1. - smoothstep(0., 0.68, uv3.y));
	ra = mix(ra, sin(6.5 * dot(uv2, uv2) - 10. * t3), t3);
	clr.a = 1. - smoothstep(ra, ra + 0.08, dot(uv4, uv4));
	clr.a *= step(pow(max(0., t3 - 0.78), 2.0), length(uv2));
	clr.a *= 1. - smoothstep(0.9, 1.0, length(2.0 * uv3 - 1.0));
	if(t < 1e-4 || t > (1. - 1e-4)) clr.a = 0.;
	return clr;
}


vec4 vines(vec2 uv)
{
	uv.y -= 0.005;
	vec2 uv2 = 2.0 * uv - 1.0;
	uv2 *= 1.1;
	float tp = atan(uv2.y, uv2.x);
	float n = sin(tp);
	
	float n2 = texture(fire_noise, vec2(uv) * vec2(1.6, 1.9) + vec2(0.1)).r;
	float laby = smoothstep(0.46, 0.475, 1.0 - n2) * smoothstep(0.5, 0.515, n2);
	vec4 clr = vec4(1.0);
	clr.rgb = texture(leaf_grad, vec2(laby, 0.0)).rgb;

	float r = 3. * length(uv2);
	clr.a = smoothstep(0.1, 0.2, sin(4.0 * (log(r) / log(2.71828 * 1.) + 0.25 * tp)));
	float begin = 2.718 - 4. * t;
	float end   = 2.718 - 4. * (1. - 4. * (max(0.75, t) - 0.75));
	clr.a *= smoothstep(begin - 0.1, begin, r) * smoothstep(end - 0.1, end, 1. - r);
	clr.a *= 1. - smoothstep(0.7, 0.8, length(2.0 * uv - 1.0));
	if(t < 1e-4 || t > (1. - 1e-4)) clr.a = 0.;

	return clr;
}

vec4 choose(vec2 uv, int which)
{
	switch(which)
	{
		case 1:
			return fireball(uv);
		case 2:
			return droplet(uv);
		case 3:
			return lightning(uv);
		case 4:
			return vines(uv);
		default:
			return vec4(0.);
	}
}

vec4 combine(vec4 a, vec4 b)
{
	return vec4(mix(a.rgb, b.rgb, b.a), a.a + b.a);
}

vec4 reaction(vec2 uv)
{
	float tt = min(t_reaction, 0.75) / 0.75;

	uv.y -= 0.005;
	vec2 uv2 = 2.0 * uv - 1.0;
	uv2 *= 1.1;

	const float tboom = 0.7;
	float te = (max(t_reaction, tboom) - tboom) / (1. - tboom);
	if(te > 1e-4)
	{
		const float wipe = 0.92;
		float tl = (max(t_reaction, wipe) - wipe) / (1. - wipe);
		vec4 expl = vec4(1.);
		float beg = 2. * te;
		float r = length(uv2);
		expl.a = 1. - step(beg, r);
		expl.a *= step(tl, r);
		expl.a *= 1. - step(1.0, r);
		return expl;
	}

	float tp = atan(uv2.y, uv2.x);

	vec4 clr4;
	if(which_a == 4 || which_b == 4)
	{
		float n2 = texture(fire_noise, vec2(uv) * vec2(1.6, 1.9) + vec2(0.1)).r;
		float laby = smoothstep(0.46, 0.475, 1.0 - n2) * smoothstep(0.5, 0.515, n2);
		clr4.rgb = texture(leaf_grad, vec2(laby, 0.0)).rgb;
	}

	vec4 clr3;
	if(which_a == 2 || which_b == 2)
	{
		float n1 = texture(water_noise, uv * vec2(0.8, 1.0) + 0.5 * vec2(0.144, 0.191) * TIME).r;
		float n2 = texture(water_noise, uv * vec2(0.6, 1.0) + 0.7 * vec2(0.123, -0.187) * TIME).r;
		float n = 0.7 *n1*n2+0.3*smoothstep(0.465, 0.475, 1.0 - (0.5 * (n1 + n2))) * smoothstep(0.5, 0.51, 0.5 * (n1 + n2));
		clr3.rgb = texture(water_grad, vec2(n, 0.0)).rgb;
	}

	vec4 clr2;
	if(which_a == 1 || which_b == 1)
	{
		float n1 = texture(fire_noise, uv * vec2(0.6, 1.0) + vec2(0.144, 0.191) * TIME).r;
		float n2 = texture(fire_noise, uv * vec2(0.4, 1.0) + vec2(0.123, -0.187) * TIME).r;
		float n = n1 * n2;
		clr2.rgb = texture(fire_grad, vec2(n, 0.0)).rgb;
	}

	vec4 clr1;
	if(which_a == 3|| which_b == 3)
	{
		float flux = 2.0 * texture(lightning_noise, vec2(0.3, uv.y)).r - 1.0;
		float xos = 0.5 + 0.06 * flux;
		float d = min(1., 0.008 / abs(xos - (0.25 + 0.5 * (uv.x + 0.00 * sin(100.0 * uv.y)))));
		clr1.rgb = texture(lightning_grad, vec2(0.4 * (sqrt(0.9 * d)), 0.0)).rgb;
	}

	vec3 all[5] = { vec3(0.),clr2.rgb,clr3.rgb,clr1.rgb,clr4.rgb };
	vec4 clr;

	float r = 3. * length(uv2);
	float osc = sin(4.0 * (log(r) / log(2.71828 * 1.1) + 0.5 * tp));
	clr.rgb = sin(4.0 * (log(r) / log(2.71828 * 3.3) + 0.25 * tp)) > 0.0 ? all[which_a] : all[which_b];
	clr.a = smoothstep(0.1, 0.2, osc);
	float begin = 2.718 - 4. * tt;
	float end   = 2.718 - 4. * (1. - 4. * (max(0.75, tt) - 0.75));
	clr.a *= smoothstep(begin - 0.1, begin, r) * smoothstep(end - 0.1, end, 1. - r);
	clr.a *= 1. - smoothstep(0.7, 0.8, length(2.0 * uv - 1.0));
	if(t_reaction < 1e-4 || t_reaction > (1. - 1e-4)) clr.a = 0.;

	return clr;
}

void fragment()
{
	COLOR = t_reaction > 1e-4 ? combine(choose(UV, which_elem), reaction(UV)) : choose(UV, which_elem);
}