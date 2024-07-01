extends BaseSpecial

@export var dash_wind_up := 0.25
@export var dash_speed := 1400
@export var wind_up_speed := 200
@export var dash_duration := 0.6
@export var dash_recovery := 0.3
@export var dash_cooldown := 0.3
@export var attack_damage := 2
@export var attack_intensity := 1.0

func special():
	if not can_use_special:
		return
	can_use_special = false
	player.attacking = true
	player.computing_movement = false
	player.velocity = Vector2.ZERO
	var dash_direction := Vector2.ZERO
	# check dash direction: left or right
	if Input.is_action_pressed("left"):
		dash_direction.x = -1
	elif Input.is_action_pressed("right") or player.facing_right:
		dash_direction.x = 1
	else:
		dash_direction.x = -1
	player.velocity = -1 * dash_direction.normalized() * wind_up_speed
	
	await get_tree().create_timer(dash_wind_up).timeout
	if not player.alive:
		return
	
	# spawn damage hitbox
	Hitbox.spawn_hitbox(player, attack_damage, Vector2.ZERO, dash_duration, 
	true, attack_intensity, Vector2(3.3, 3.3))
	player.velocity = dash_direction.normalized() * dash_speed
	await get_tree().create_timer(dash_duration).timeout
	
	player.movement_velocity.y = (player.velocity.y) / 20
	player.computing_movement = true
	await get_tree().create_timer(dash_recovery).timeout
	
	player.attacking = false
	await get_tree().create_timer(dash_cooldown).timeout
	
	can_use_special = true

