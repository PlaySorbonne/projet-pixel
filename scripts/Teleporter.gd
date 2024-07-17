extends Area2D
class_name Teleporter

@export var otherTeleporter : Teleporter
var ignored_objects : Array = []

func _on_body_entered(body : Node2D):
	var body_index = ignored_objects.find(body)
	if body_index >= 0:
		ignored_objects.remove_at(body_index)
		return
	otherTeleporter.ignored_objects.append(body)
	var vector_to_body : Vector2 = body.global_position - global_position
	body.global_position = otherTeleporter.global_position + vector_to_body
	await get_tree().create_timer(0.15).timeout
	otherTeleporter.ignored_objects.erase(body)
