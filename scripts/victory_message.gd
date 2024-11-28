extends CanvasLayer
class_name EndGameScreen

func _ready():
	$AnimationPlayer.play("end_anim")

func remove():
	$AnimationPlayer.play("remove")
	await $AnimationPlayer.animation_finished
	queue_free()
