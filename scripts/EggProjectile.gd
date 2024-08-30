extends CharacterBody2D
class_name EggProjectile

const EGG_PROJECTILE = preload("res://scenes/Characters/Evolutions/Specials/EggProjectile.tscn")
const SPAWN_OFFSET = Vector2(0.0, 50.0)

var hit_damage := 3
var hit_duration := 1.0
var egg_speed := 1400.0
var hit_size := 1.0
var hit_intensity := 1.0

var parent_player : PlayerCharacter 
var explosion_triggered := false

static func spawn_egg_projectile(player_char : PlayerCharacter, special : SpecialMascot):
	var egg : EggProjectile = EGG_PROJECTILE.instantiate()
	egg.hit_damage = special.egg_hit_damage
	egg.hit_duration = special.egg_hit_duration
	egg.egg_speed = special.egg_speed
	egg.hit_size = special.egg_hit_size
	egg.hit_intensity = special.egg_hit_intensity
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
	false, hit_intensity, Vector2(hit_size, hit_size))
	queue_free()
