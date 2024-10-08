extends CharacterBody2D
class_name EggProjectile

const EGG_PROJECTILE = preload("res://scenes/Characters/Evolutions/Specials/EggProjectile.tscn")
const SPAWN_OFFSET = Vector2(0.0, 18.5)
const EXPLOSION_RES = preload("res://resources/images/fx/explosion/explosion_anim_sprite.tscn")
const DEFAULT_EGG_SPRITE_SCALE := Vector2(0.15, 0.15)

@export var audios_egg : Array[AudioStream] = []

var hit_damage := 3
var hit_duration := 1.0
var egg_speed := 1400.0
var hit_size := 1.0
var hit_intensity := 1.0

var parent_player : PlayerCharacter 
var explosion_triggered := false

static func spawn_egg_projectile(player_char : PlayerCharacter, 
special : SpecialMascot, on_floor := false):
	if on_floor:
		var hitbox : Hitbox = Hitbox.spawn_hitbox(player_char, 
		special.egg_hit_damage, player_char.global_position, 
		special.egg_hit_duration, false, special.egg_hit_intensity, 
		Vector2(special.egg_hit_size, special.egg_hit_size))
		hitbox.no_particles()
		var explosion : AnimatedSprite2D = EXPLOSION_RES.instantiate()
		explosion.scale *= special.egg_hit_size
		explosion.global_position = hitbox.global_position
		GameInfos.world.add_child(explosion)
	else:
		var egg_offset : Vector2 = SPAWN_OFFSET
		var egg : EggProjectile = EGG_PROJECTILE.instantiate()
		egg.hit_damage = special.egg_hit_damage
		egg.hit_duration = special.egg_hit_duration
		egg.egg_speed = special.egg_speed
		egg.hit_size = special.egg_hit_size
		egg.hit_intensity = special.egg_hit_intensity
		egg.position = player_char.global_position + egg_offset
		egg.parent_player = player_char
		GameInfos.world.add_child(egg)

func _ready():
	velocity = Vector2.DOWN * egg_speed
	$AudioPop.stream = audios_egg.pick_random()
	$AudioPop.play()
	var tween := create_tween()
	tween.tween_property($Sprite, "scale", DEFAULT_EGG_SPRITE_SCALE, 0.2)
	if parent_player.is_on_floor():
		_on_area_2d_body_entered(null)

func _physics_process(_delta):
	move_and_slide()

func _on_area_2d_body_entered(body):
	if explosion_triggered or body == parent_player:
		return
	explosion_triggered = true
	await get_tree().create_timer(0.05).timeout
	var hitbox : Hitbox = Hitbox.spawn_hitbox(parent_player, hit_damage, global_position, hit_duration, 
	false, hit_intensity, Vector2(hit_size, hit_size))
	hitbox.no_particles()
	var explosion : AnimatedSprite2D = EXPLOSION_RES.instantiate()
	explosion.scale *= hit_size
	explosion.global_position = hitbox.global_position
	GameInfos.world.add_child(explosion)
	queue_free()
