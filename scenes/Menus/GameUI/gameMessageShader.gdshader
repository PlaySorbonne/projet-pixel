shader_type canvas_item;

//void vertex() {
	//// Called for every vertex the material is visible on.
//}

uniform float intensity = 0.0;
uniform vec3 targetColor = vec3(1.0, 1.0, 1.0);

void fragment() {
	COLOR.rgb = mix(COLOR.rgb, targetColor, intensity);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
