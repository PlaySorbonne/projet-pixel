extends CanvasLayer
class_name EndGameScreen

signal input_pressed

var can_press_input := false

func _ready():
	$AnimationPlayer.play("end_anim")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("idle")
	await get_tree().create_timer(0.9).timeout
	can_press_input = true

func _process(delta: float) -> void:
	if can_press_input and Input.is_action_just_pressed(
			"jump") or Input.is_action_just_pressed("attack"):
		can_press_input = false
		remove()

func remove():
	$AnimationPlayer.play("remove")
	$AudioTrans.play()
	await $AnimationPlayer.animation_finished
	emit_signal("input_pressed")
	await get_tree().create_timer(0.5).timeout
	queue_free()
