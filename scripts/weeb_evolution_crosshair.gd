extends Node2D

var followed_actor : PlayerCharacter

func _ready():
	$AnimationPlayer.play("evolve_to_weeb")
	visible = true
	await $AnimationPlayer.animation_finished
	queue_free()

func _process(_delta):
	if is_instance_valid(followed_actor):
		global_position = followed_actor.global_position
	else:
		queue_free()
