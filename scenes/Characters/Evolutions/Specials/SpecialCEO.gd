extends BaseSpecial

const STATIONARY_THRESHOLD := 5.0

@export var dash_wind_up := 0.25
@export var dash_speed := 1400.0
@export var wind_up_speed := 200.0
@export var dash_duration := 0.6
@export var dash_recovery := 0.3
@export var dash_cooldown := 0.3
@export var attack_damage := 2
@export var attack_intensity := 1.0
@export var attack_size := 3.3
@export var bonk_power := Vector2(-2500, -1000)

var time_stationnary := 0.0
var last_player_pos_x := -99999.0
var dash_direction := Vector2.ZERO
var hitbox : Hitbox = null

func _ready():
	set_process(false)

func _process(delta):
	if abs(player.position.x - last_player_pos_x) < STATIONARY_THRESHOLD:
		time_stationnary += delta
		if time_stationnary > 0.05:
			bonk()
	else:
		last_player_pos_x = player.position.x
		time_stationnary = 0.0

func bonk():
	set_process(false)
	player.controller_vibration(1.0, 0.7)
	player.knockback_velocity = Vector2(
		dash_direction.x * bonk_power.x,
		bonk_power.y
	)
	player.movement_velocity.y = (player.velocity.y) / 20
	player.computing_movement = true
	if hitbox != null:
		hitbox.end_hitbox()
		hitbox = null
	GameInfos.camera_utils.shake()
	if get_tree():
		await get_tree().create_timer(dash_recovery).timeout
	
	player.attacking = false
	
	if get_tree():
		await get_tree().create_timer(dash_cooldown).timeout
	
	can_use_special = true

func special():
	if not can_use_special:
		return
	can_use_special = false
	player.attacking = true
	player.computing_movement = false
	player.velocity = Vector2.ZERO
	player.set_animation(true)
	dash_direction = Vector2(1.0, 0.0)
	# check dash direction: left or right
	if player.left_pressed or not player.facing_right:
		dash_direction.x = -1
	elif player.right_pressed:
		dash_direction.x = 1
	
	if not player.alive:
		player.attacking = false
		can_use_special = true
		return
	
	# spawn damage hitbox
	hitbox = Hitbox.spawn_hitbox(player, attack_damage, Vector2.ZERO, 
	-1.0, true, attack_intensity, Vector2(attack_size, attack_size))
	hitbox.no_particles()
	player.velocity = dash_direction.normalized() * dash_speed
	
	set_process(true)
