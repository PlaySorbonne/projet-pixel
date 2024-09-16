extends Node2D

var followed_actor : PlayerCharacter

func _ready():
	$AnimationPlayer.play("init")
	await get_tree().create_timer(0.01, true, false, true).timeout
	visible = true
	await get_tree().create_timer(0.1, true, false, true).timeout
	$AnimationPlayer.play("evolve_to_weeb")
	await $AnimationPlayer.animation_finished
	queue_free()

func _process(_delta):
	global_position = followed_actor.global_position
