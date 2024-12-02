extends Node
class_name AI_Inputs

enum Directions {Left, Right, Down}

const UPDATE_TIME_LIMIT := 0.35
const MIN_TIME_BETWEEN_SPECIALS := 3.5
const MIN_TIME_BETWEEN_ATTACKS := 0.1
const MIN_TIME_BETWEEN_JUMPS := 0.8

var time_between_specials := MIN_TIME_BETWEEN_SPECIALS
var time_between_attacks := MIN_TIME_BETWEEN_ATTACKS
var time_between_jumps := MIN_TIME_BETWEEN_JUMPS

var time_since_special := 0.0
var time_since_attack := 0.0
var time_since_jump := 0.0
var update_time := 0.0

var reaction_time := 0.1

var enemy_ids : Array[int] = []
var enemies : Array[PlayerCharacter] = []
var enemy_distances : Array[float] = []
var enemy_directions : Array[Vector2] = []
var enemy_hitpoints : Array[int] = []
var enemy_position_differences : Array[Vector2] = []

@onready var player : PlayerCharacter = self.get_parent()

func _ready() -> void:
	for p_id : int in GameInfos.players.keys():
		if p_id != player.player_ID:
			enemy_ids.append(p_id)

func player_special() -> void:
	player.special()
	time_since_special = 0.0
	time_between_specials = randf_range(MIN_TIME_BETWEEN_SPECIALS, MIN_TIME_BETWEEN_SPECIALS*3)

func player_attack() -> void:
	player.attack()
	time_since_attack = 0.0
	time_between_attacks = randf_range(MIN_TIME_BETWEEN_ATTACKS, MIN_TIME_BETWEEN_ATTACKS*2)

func player_jump() -> void:
	player.jump()
	time_since_jump = 0.0
	time_between_jumps = randf_range(MIN_TIME_BETWEEN_JUMPS, MIN_TIME_BETWEEN_JUMPS*3)

func random_t() -> float:
	return randf_range(0.25, 1.25)

func player_press_direction(dir : Directions) -> void:
	match dir:
		Directions.Left:
			player.left_pressed = true
			$TimerLeft.start(random_t())
		Directions.Right:
			player.right_pressed = true
			$TimerRight.start(random_t())
		Directions.Down:
			
			player.down_pressed = true
			$TimerDown.start(random_t())

func attack_closest_enemy(enemy_pos_diff : Vector2) -> void:
	# attacks
	if time_since_attack > time_between_attacks:
		if player.facing_right:
			if enemy_pos_diff.x > 0.0:
				player_attack()
				return
		elif enemy_pos_diff.x < 0.0:
			player_attack()
			return
	# movement
	if enemy_pos_diff.x > 0.0:
		player_press_direction(Directions.Left)
	elif enemy_pos_diff.x < 0.0:
		player_press_direction(Directions.Right)
	if enemy_pos_diff.y < -50.0:
		player_press_direction(Directions.Down)
	elif enemy_pos_diff.y > 50.0:
		player_jump()

func update_enemies(delta : float, force_update := false) -> void:
	# update various timers
	update_time -= delta
	time_since_attack += delta
	time_since_special += delta
	time_since_jump += delta
	
	# update enemies
	if update_time > 0.0 and not force_update:
		return
	update_time = UPDATE_TIME_LIMIT
	enemies = []
	enemy_distances = []
	enemy_directions = []
	enemy_hitpoints = []
	enemy_position_differences = []
	var location := player.get_attack_location()
	for id : int in enemy_ids:
		var current_enemy : PlayerCharacter = GameInfos.players[id]
		var enemy_location : Vector2 = current_enemy.global_position
		enemies.append(GameInfos.players[id])
		enemy_distances.append(location.distance_squared_to(enemy_location))
		enemy_directions.append(location.direction_to(enemy_location))
		enemy_hitpoints.append(current_enemy.hitpoints)
		enemy_position_differences.append(location - enemy_location)

func _on_timer_left_timeout() -> void:
	player.left_pressed = false

func _on_timer_right_timeout() -> void:
	player.right_pressed = false

func _on_timer_down_timeout() -> void:
	player.down_pressed = false

func _on_timer_down_spacing_timeout() -> void:
	player_press_direction(Directions.Down)
	$TimerDownSpacing.start(random_t() * 4)

func _process(_delta: float) -> void:
	pass
	# actions:
		# move (left/right/drop down)
		# jump/stop_jump
		# use special
		# attack
	# considerations:
		# ascended weeb
		# other players
		# cassette
		# platforms
		# semi-solid platforms
	
	# COMMANDS:
		# player.right_pressed
		# player.left_pressed
		# player.up_pressed
		# player.down_pressed
		
		# player.jump()
		# player.stop_jump()
		
		# player.attack()
		# player.special()
