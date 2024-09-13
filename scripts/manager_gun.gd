extends Node2D
class_name ManagerGun

func _ready():
	visible = false

func play_load():
	$GunSprite/Gunimation.play("gun")
	visible = true

func play_shoot():
	$GunSprite/Gunimation.play("gun_boom")
	await $GunSprite/Gunimation.animation_finished
	visible = false
