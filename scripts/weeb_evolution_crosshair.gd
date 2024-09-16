extends Node2D

var followed_actor : PlayerCharacter

func _ready():
	$AnimationPlayer.play("evolve_to_weeb")
	visible = true
	await $AnimationPlayer.animation_finished
	queue_free()

func _process(_delta):
	global_position = followed_actor.global_position
