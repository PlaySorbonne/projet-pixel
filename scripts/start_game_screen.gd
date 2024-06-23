extends CanvasLayer
class_name StartGameScreen

signal countdown_finished

func _ready():
	$Label.position = Vector2(1920, 1080)

func countdown():
	$AnimationPlayer.play("start_anim")
	visible = true
	await $AnimationPlayer.animation_finished
	queue_free()

func signal_countdown_end():
	emit_signal("countdown_finished")
