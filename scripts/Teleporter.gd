@tool
extends Area2D
class_name Teleporter

@export var teleport_offset := Vector2(0.0, -500.0):
	set(value):
		teleport_offset = value
		$Marker2D.global_position = position + value
@export var keep_offset := true

func _ready():
	$Marker2D.global_position = position + teleport_offset

func _on_body_entered(body : Node2D):
	var new_pos : Vector2
	if keep_offset:
		new_pos = body.position + teleport_offset.rotated(rotation)
	else:
		new_pos = position + teleport_offset.rotated(rotation)
	if body.has_method("force_position"):
		body.force_position(new_pos)
	else:
		body.position = new_pos
