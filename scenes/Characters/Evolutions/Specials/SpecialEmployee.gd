extends BaseSpecial

@export var fall_speed := 2000.0
@export var damage := 3
@export var hitbox_size := 3.0
@export var hit_duration := 0.25
@export var fall_recovery := 0.65
@export var delay_between_jump_and_fall := 0.35
@export var jump_power := 3000.0
@export var attack_intensity := 2.0
@export var mid_air_wind_up := 0.75

func _ready():
	set_process(false)

func _process(_delta):
	if player.is_on_floor():
		set_process(false)
		special_end()

func special():
	if not can_use_special:
		return
	can_use_special = false
	player.attacking = true
	if player.is_on_floor():
		player.knockback_velocity.y -= jump_power
		await get_tree().create_timer(delay_between_jump_and_fall).timeout
	else:
		player.computing_movement = false
		await get_tree().create_timer(mid_air_wind_up).timeout
	player.computing_movement = false
	player.velocity = Vector2.DOWN * fall_speed
	set_process(true)

func special_end():
	Hitbox.spawn_hitbox(player, damage, Vector2.ZERO, hit_duration, true, attack_intensity, 
		Vector2(hitbox_size, hitbox_size))
	player.movement_velocity = Vector2.ZERO
	await get_tree().create_timer(fall_recovery).timeout
	
	player.knockback_velocity = Vector2.ZERO
	player.computing_movement = true
	player.attacking = false
	can_use_special = true
