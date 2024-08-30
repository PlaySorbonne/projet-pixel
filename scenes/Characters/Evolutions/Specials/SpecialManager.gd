extends BaseSpecial

@export var attack_damage := 2
@export var attack_size := 3.0
@export var attack_intensity := 1.0
@export var dash_speed := 2000.0
@export var dash_duration := 0.3
@export var dash_cooldown := 0.3

func special():
	if not can_use_special:
		return
	var dash_direction := Vector2.ZERO
	if Input.is_action_pressed("down"):
		dash_direction.y += -1
	if Input.is_action_pressed("left"):
		dash_direction.x = 1
	if Input.is_action_pressed("right"):
		dash_direction.x += -1
	if dash_direction == Vector2.ZERO:
		return
	can_use_special = false
	player.attacking = true
	player.computing_movement = false
	
	# Spawn attack hitbox
	Hitbox.spawn_hitbox(player, attack_damage, player.global_position, dash_duration, 
	false, attack_intensity, Vector2(attack_size, attack_size))
	
	player.velocity = dash_direction.normalized() * dash_speed
	await get_tree().create_timer(dash_duration).timeout
	player.knockback_velocity.y = (player.velocity.y) / 20
	player.computing_movement = true
	player.attacking = false
	
	await get_tree().create_timer(dash_cooldown).timeout
	can_use_special = true
