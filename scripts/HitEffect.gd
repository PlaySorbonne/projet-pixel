extends Node
class_name CharacterSpriteEffect

@export var sprite_path : NodePath
@onready var sprite_node : Node2D = get_node(sprite_path)

func trigger_hit_effect(duration := 1.0, blink_delay := 0.3):
	for _i in range(int(duration / blink_delay)):
		sprite_node.material.set_shader_parameter("in_hit_effect", true)
		await get_tree().create_timer(blink_delay/2.0).timeout
		sprite_node.material.set_shader_parameter("in_hit_effect", false)
		await get_tree().create_timer(blink_delay/2.0).timeout

func set_special_availability(availability : bool):
	var new_color : Color
	var time : float
	if availability:
		new_color = Color.WHITE
		time = 0.25
	else:
		new_color = Color.DARK_GRAY
		time = 0.1
	var tween := create_tween()
	tween.tween_property(sprite_node, "self_modulate", new_color, time)
