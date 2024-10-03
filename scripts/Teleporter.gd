@tool
extends Area2D
class_name Teleporter

@export var teleport_offset := Vector2(0.0, -500.0):
	set(value):
		teleport_offset = value
		$Marker2D.position = value

func _on_body_entered(body : Node2D):
	body.position += teleport_offset.rotated(rotation)
