extends BaseSpecial
class_name SpecialManager

const GUN_RES = preload("res://scenes/Characters/Evolutions/Specials/ManagerGun.tscn")

@export var attack_damage := 2
@export var attack_size := 3.0
@export var attack_intensity := 1.0

@export var dash_speed := 2000.0
@export var dash_duration := 0.3
@export var dash_cooldown := 0.3

@export var dash_windup := 0.3

@export var bullet_hit_damage : int = 1   
@export var bullet_speed := 1400.0
@export var bullet_size := 1.0
@export var bullet_hit_intensity := 1.0

var player_gun : ManagerGun

func _ready():
	await get_tree().create_timer(0.4).timeout
	player_gun = GUN_RES.instantiate()
	player.add_child(player_gun)
	player_gun.scale = Vector2.ONE * bullet_size * 1.5
	player_gun.position = Vector2(1.0, 0.0) * 50.0

func special():
	if not can_use_special:
		return
	var dash_direction : float
	if player.facing_right:
		dash_direction = -1.0
	else:
		dash_direction = 1.0
	can_use_special = false
	player.attacking = true
	#player.velocity = Vector2.ZERO
	#player.computing_movement = false
	player_gun.play_load()
	
	await get_tree().create_timer(dash_windup).timeout
	
	player_gun.play_shoot()
	
	# Spawn attack hitbox
	Bullet.spawn_bullet(player, self)
	
	await get_tree().create_timer(0.05).timeout
	
	player.knockback_velocity = Vector2(dash_direction, -0.25) * dash_speed
	player.attacking = false
	
	await get_tree().create_timer(dash_cooldown).timeout
	can_use_special = true
