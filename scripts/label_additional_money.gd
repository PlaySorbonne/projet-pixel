extends Label
class_name MoneyAdder

func set_slow() -> void:
	$AnimationPlayer.speed_scale = 0.3

func _ready() -> void:
	$AnimationPlayer.play("anim")
	await $AnimationPlayer.animation_finished
	queue_free()
