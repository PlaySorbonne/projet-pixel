extends CanvasLayer
class_name StartGameScreen

signal countdown_finished

func countdown():
	$AnimationPlayer.play("start_anim")
	await $AnimationPlayer.animation_finished
	queue_free()

func signal_countdown_end():
	emit_signal("countdown_finished")
