extends Node
class_name HitEffect

@export var sprite_path : NodePath
@onready var sprite_node : Node2D = get_node(sprite_path)

func trigger_hit_effect(duration := 1.0, blink_delay := 0.2):
	for _i in range(int(duration / blink_delay)):
		sprite_node.modulate = Color(100, 1, 1)
		await get_tree().create_timer(blink_delay/2.0).timeout
		sprite_node.modulate = Color(1, 1, 1)
		await get_tree().create_timer(blink_delay/2.0).timeout
