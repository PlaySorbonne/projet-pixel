@tool
extends CanvasLayer
class_name EndGameScreen

func _ready():
	$AnimationPlayer.play("end_anim")

