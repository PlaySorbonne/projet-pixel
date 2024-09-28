//shader by CasualGarageCoder, updated to Godot 4
shader_type canvas_item;

uniform float chaos : hint_range(0., 100.) = 1.;
uniform float radius : hint_range(0., 1.) = 1.;
uniform float attenuation : hint_range(0., 10.) = 10.;
uniform float divider_green = 1.;
uniform float divider_blue = 1.;
uniform float time_divider = 2.;

varying vec2 amount_r;
varying vec2 amount_g;
varying vec2 amount_b;

float rand(vec2 co){
    return (sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453) - .5;
}

void vertex() {
    vec2 shifted_uv = (UV * 2.) - 1.;
	float t = TIME / time_divider;
    amount_r = normalize(
        vec2(rand(t * 0.3 * shifted_uv),
        rand(t * 0.64 * shifted_uv)));
    amount_g = normalize(
        vec2(rand(TIME * 0.5 * shifted_uv),
        rand(t * 0.7 * shifted_uv)));
    amount_b = normalize(
        vec2(rand(TIME * 0.17 * shifted_uv),
        rand(t * 0.23 * shifted_uv)));
}

void fragment() {
	vec2 chaos_v = vec2(chaos, -chaos) * TEXTURE_PIXEL_SIZE;

	float dist = length((UV - vec2(0.5)) * 2.);
	float att = clamp(dist / radius, 0., 1.);

	chaos_v *= 1.; // - pow(att, attenuation);

	vec3 new_color = vec3(
		texture(TEXTURE, UV + chaos_v * amount_r).r,
		texture(TEXTURE, UV + chaos_v * amount_g).g,
		texture(TEXTURE, UV + chaos_v * amount_b).b
	);

	COLOR = vec4(
        new_color.r,
        new_color.g / divider_green,
        new_color.b / divider_blue,
        clamp(new_color.r + new_color.g + new_color.b, 0., 1.));
}