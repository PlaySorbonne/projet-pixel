extends CharacterBody2D


@export var hit_damage := 3
@export var hit_duration := 1.0
@export var egg_speed := 1400.0

var parent_player : PlayerCharacter 

func _ready():
	velocity = Vector2.DOWN * egg_speed

func _physics_process(_delta):
	move_and_slide()



func _on_area_2d_body_entered(body):
	Hitbox.spawn_hitbox(parent_player, hit_damage, Vector2.ZERO, hit_duration, 
	false, 1, Vector2(4.0, 4.0))
