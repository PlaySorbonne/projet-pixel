extends CanvasLayer
class_name EndGameScreen

signal input_pressed

var can_press_input := false

func _ready():
	
	$AnimationPlayer.play("end_anim")
	await $AnimationPlayer.animation_finished
	can_press_input = true

func _process(delta: float) -> void:
	if can_press_input and Input.is_action_just_pressed(
			"jump") or Input.is_action_just_pressed("attack"):
		can_press_input = false
		remove()

func remove():
	$AnimationPlayer.play("remove")
	await $AnimationPlayer.animation_finished
	emit_signal("input_pressed")
	queue_free()
