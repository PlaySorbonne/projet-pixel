shader_type canvas_item;

uniform vec4 base_color : source_color;
uniform vec4 replace_color : source_color;
uniform float replace_threshold : hint_range(0.0, 1.0, 0.001);

void fragment() {
	float replace_distance = length(texture(TEXTURE, UV).rgba - base_color.rgba);
	
	if(replace_distance < replace_threshold){
		COLOR = replace_color;
	}
}
