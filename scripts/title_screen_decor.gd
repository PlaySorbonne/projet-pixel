extends Node2D
class_name MenuDecor

@export var play_from_start : bool = true
@export var background_modulate := Color(1.0, 0.1, 0.56):
	set(value):
		background_modulate = value
		$DecorPlaceholder.modulate = background_modulate

func _ready():
	if play_from_start:
		$AnimationPlayer.play("idle")
	else:
		$AnimationPlayer.play_backwards("idle")
	$DecorPlaceholder.modulate = background_modulate
