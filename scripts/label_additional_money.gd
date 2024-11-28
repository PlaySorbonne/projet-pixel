extends Label
class_name MoneyAdder

func _ready() -> void:
	$AnimationPlayer.play("anim")
	await $AnimationPlayer.animation_finished
	queue_free()
