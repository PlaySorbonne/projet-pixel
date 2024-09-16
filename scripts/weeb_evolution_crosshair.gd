extends Node2D

func _ready():
	$AnimationPlayer.play("evolve_to_weeb")
	await get_tree().create_timer(0.05).timeout
	visible = true
	await $AnimationPlayer.animation_finished
	queue_free()
