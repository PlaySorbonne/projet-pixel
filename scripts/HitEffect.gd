extends Node
class_name CharacterSpriteEffect

@export var sprite_path : NodePath
@onready var sprite_node : Node2D = get_node(sprite_path)

func trigger_hit_effect(duration := 1.0, blink_delay := 0.2):
	for _i in range(int(duration / blink_delay)):
		sprite_node.modulate = Color(100, 1, 1)
		await get_tree().create_timer(blink_delay/2.0).timeout
		sprite_node.modulate = Color(1, 1, 1)
		await get_tree().create_timer(blink_delay/2.0).timeout

func set_special_availability(availability : bool):
	var new_color : Color
	if availability:
		new_color = Color.WHITE
	else:
		new_color = Color.DARK_GRAY
	var tween := create_tween()
	tween.tween_property(sprite_node, "self_modulate", new_color, 0.15)
