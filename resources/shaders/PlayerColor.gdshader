shader_type canvas_item;

const vec3 HIT_COLOR = vec3(100.0, 0.5, 0.5);
uniform bool in_hit_effect = false;
uniform vec4 base_color : source_color;
uniform vec4 replace_color : source_color;
uniform float replace_threshold : hint_range(0.0, 1.0, 0.001);

void fragment() {
	if (in_hit_effect){
		COLOR.rgb = HIT_COLOR;
	} else {
		float replace_distance = length(texture(TEXTURE, UV).rgba - base_color.rgba);
		if (replace_distance < replace_threshold) {
			COLOR.rgb = replace_color.rgb;
		}
	}
}
