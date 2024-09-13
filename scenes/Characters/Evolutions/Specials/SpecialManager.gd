extends BaseSpecial
class_name SpecialManager

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
	player.velocity = Vector2.ZERO
	player.computing_movement = false
	
	await get_tree().create_timer(dash_windup).timeout
	
	# Spawn attack hitbox
	Bullet.spawn_bullet(player, self)
	
	player.knockback_velocity.x = dash_direction * dash_speed
	player.knockback_velocity.y = (player.velocity.y) / 20
	player.computing_movement = true
	player.attacking = false
	
	await get_tree().create_timer(dash_cooldown).timeout
	can_use_special = true
