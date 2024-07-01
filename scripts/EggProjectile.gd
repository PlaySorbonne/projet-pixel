extends CharacterBody2D
class_name EggProjectile

const EGG_PROJECTILE = preload("res://scenes/Characters/Evolutions/Specials/EggProjectile.tscn")
const SPAWN_OFFSET = Vector2(0.0, 50.0)

@export var hit_damage := 3
@export var hit_duration := 1.0
@export var egg_speed := 1400.0

var parent_player : PlayerCharacter 
var explosion_triggered := false

static func spawn_egg_projectile(player_char : PlayerCharacter):
	var egg : EggProjectile = EGG_PROJECTILE.instantiate()
	egg.position = player_char.global_position + SPAWN_OFFSET
	egg.parent_player = player_char
	GameInfos.world.add_child(egg)

func _ready():
	velocity = Vector2.DOWN * egg_speed

func _physics_process(_delta):
	move_and_slide()

func _on_area_2d_body_entered(body):
	if explosion_triggered:
		return
	explosion_triggered = true
	await get_tree().create_timer(0.05).timeout
	Hitbox.spawn_hitbox(parent_player, hit_damage, global_position, hit_duration, 
	false, 1, Vector2(4.0, 4.0))
	queue_free()
