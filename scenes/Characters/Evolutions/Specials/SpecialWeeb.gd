extends BaseSpecial


@export var dash_speed := 2000.0
@export var dash_duration := 0.125
@export var dash_cooldown := 0.25
@export var dash_audio : XYZ_AudioPitchRandomizer = null 

func special():
	if not can_use_special:
		return
	var dash_direction := Vector2.ZERO
	if player.up_pressed:
		dash_direction.y = -1
	if player.down_pressed:
		dash_direction.y += 1
	if player.left_pressed:
		dash_direction.x = -1
	if player.right_pressed:
		dash_direction.x += 1
	if dash_direction == Vector2.ZERO:
		if player.facing_right:
			dash_direction.x = 1.0
		else:
			dash_direction.x = -1.0
	can_use_special = false
	player.controller_vibration(0.5, 0.4)
	dash_audio.play_random_pitch()
	player.attacking = true
	player.computing_movement = false
	player.velocity = dash_direction.normalized() * dash_speed
	await get_tree().create_timer(dash_duration).timeout
	player.movement_velocity.y = (player.velocity.y) / 20
	player.computing_movement = true
	player.attacking = false
	
	
	await get_tree().create_timer(dash_cooldown).timeout
	can_use_special = true
