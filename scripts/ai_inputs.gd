extends Node
class_name AI_Inputs

enum Directions {Left, Right, Down, Up}
enum Difficulty {Easy, Mid, Hard}

const UPDATE_TIME_LIMIT := 0.35


@export var max_attack_radius : float = 250.0
@export var min_attack_radius : float = 25.0

var min_time_between_specials := 3.5
var min_time_between_attacks := 0.15
var min_time_between_jumps := 1.4
var min_time_chosen_enemy := 4.0
var reaction_time := 0.3

var time_between_specials := min_time_between_specials
var time_between_attacks := min_time_between_attacks
var time_between_jumps := min_time_between_jumps

var time_since_special := 0.0
var time_since_attack := 0.0
var time_since_jump := 0.0
var update_time := 0.0
var reacting_time := 0.0
var time_since_blocked := 0.0

var enemy_ids : Array[int] = []
var enemies : Array[PlayerCharacter] = []
var enemy_distances : Array[float] = []
var enemy_directions : Array[Vector2] = []
var enemy_hitpoints : Array[int] = []
var enemy_position_differences : Array[Vector2] = []

var chosen_enemy : int
var special_enemy : Node2D = null
var is_moving := false
var last_position : Vector2

@onready var player : PlayerCharacter = self.get_parent()

func _ready() -> void:
	for p_id : int in GameInfos.players.keys():
		if p_id != player.player_ID:
			enemy_ids.append(p_id)
	_on_timer_chosen_enemy_timeout()
	set_difficulty(player.ai_difficulty)

func set_difficulty(difficulty : Difficulty) -> void:
	match difficulty:
		Difficulty.Easy:
			reaction_time = 0.8
			min_time_between_specials = 6.0
			min_time_between_attacks = 1.1
			min_time_between_jumps = 3.4
			min_time_chosen_enemy = 5.0
		Difficulty.Mid:
			reaction_time = 0.25
			min_time_between_specials = 3.5
			min_time_between_attacks = 0.15
			min_time_between_jumps = 1.7
			min_time_chosen_enemy = 4.0
		Difficulty.Hard:
			reaction_time = 0.0
			min_time_between_specials = 2.3
			min_time_between_attacks = 0.1
			min_time_between_jumps = 0.8
			min_time_chosen_enemy = 3.0

func player_special() -> void:
	player.special()
	time_since_special = 0.0
	time_between_specials = randf_range(min_time_between_specials, min_time_between_specials*3)

func player_attack() -> void:
	player.attack()
	time_since_attack = 0.0
	time_between_attacks = randf_range(min_time_between_attacks, min_time_between_attacks*2)

func player_jump() -> void:
	player.jump()
	time_since_jump = 0.0
	time_between_jumps = randf_range(min_time_between_jumps, min_time_between_jumps*3)

func random_t() -> float:
	return randf_range(0.1, 0.5)

func player_press_direction(dir : Directions) -> void:
	is_moving = true
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
		Directions.Up:
			player.down_pressed = true
			$TimerDown.start(random_t())

func player_tap_direction(dir : Directions) -> void:
	match dir:
		Directions.Left:
			player.left_pressed = true
			$TimerLeft.start(0.05)
		Directions.Right:
			player.right_pressed = true
			$TimerRight.start(0.05)
		Directions.Down:
			player.down_pressed = true
			$TimerDown.start(0.05)
		Directions.Up:
			player.up_pressed = true
			$TimerUp.start(0.05)

func attack_cassette() -> void:
	special_enemy = GameInfos.anime_box
	attack_enemy(false)

func check_chosen_enemy() -> bool:
	if len(enemies) == 0:
		return false
	if is_instance_valid(enemies[chosen_enemy]) and enemies[chosen_enemy].alive:
		return true
	else:
		return false

func attack_enemy(use_chosen_enemy := true) -> void:
	if reacting_time < reaction_time or len(enemies) == 0:
		return
	reacting_time = 0.0
	#print("ai attack_enemy -> chosen enemy:", chosen_enemy)
	var enemy_pos_diff : Vector2
	if use_chosen_enemy:
		if not check_chosen_enemy():
			_on_timer_chosen_enemy_timeout()
		enemy_pos_diff = enemy_position_differences[chosen_enemy]
	else:
		enemy_pos_diff = player.global_position - special_enemy.global_position
	#print("enemy_pos_diff =", enemy_pos_diff)
	# attacks
	if time_since_attack > time_between_attacks:
		if enemy_pos_diff.x < 0.0: # enemy to the right
			if enemy_pos_diff.x > -max_attack_radius:
				if player.facing_right:
					#print("\tattacking enemy to the right: "+ str(enemy_pos_diff.x) + " > -" + str(max_attack_radius))
					player_attack()
					return
				else:
					player_tap_direction(Directions.Right)
			else:
				pass
				#print("\tenemy to the right, but too far: "+str(enemy_pos_diff.x) + " <= -" + str(max_attack_radius))
		elif enemy_pos_diff.x < max_attack_radius:
			if not player.facing_right:
				#print("\tattacking enemy to the left: "+ str(enemy_pos_diff.x) + " < " + str(max_attack_radius))
				player_attack()
				return
			else:
				player_tap_direction(Directions.Left)
		else:
			pass
			#print("\tenemy to the left, but too far: "+ str(enemy_pos_diff.x) + " >= " + str(max_attack_radius))
	
	# movement
	if enemy_pos_diff.x > min_attack_radius:
		#print("\tgoing left"+str(enemy_pos_diff.x) + " > " + str(min_attack_radius))
		player_press_direction(Directions.Left)
	elif enemy_pos_diff.x < -min_attack_radius:
		#print("\tgoing right"+str(enemy_pos_diff.x) + " < -" + str(min_attack_radius))
		player_press_direction(Directions.Right)
	if enemy_pos_diff.y < -50.0:
		#print("\tEnemy beside me"+str(enemy_pos_diff.y) + " < -50.0")
		player_press_direction(Directions.Down)
	elif enemy_pos_diff.y > 50.0:
		#print("\tEnemy above me"+str(enemy_pos_diff.y) + " > 50.0")
		player_jump()
	
	# jump/drop down if obstacle detected
	if is_moving:
		if time_since_blocked > 0.2 and (
					abs(player.global_position.x) - abs(last_position.x) < 5.0):
			player_tap_direction(Directions.Down)
			player_jump()
		else:
			time_since_blocked = 0.0
			last_position = player.global_position

func update_enemies(delta : float, force_update := false) -> void:
	# update various timers
	update_time -= delta
	reacting_time += delta
	time_since_attack += delta
	time_since_special += delta
	time_since_jump += delta
	time_since_blocked += delta
	
	# random jumps
	if time_since_jump > time_between_jumps:
		time_since_jump = 0.0
		player_jump()
		time_between_jumps = randf_range(min_time_between_jumps, min_time_between_jumps * 3.0)
	
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
		if current_enemy.team == player.team:
			continue
		enemies.append(GameInfos.players[id])
		enemy_distances.append(location.distance_squared_to(enemy_location))
		enemy_directions.append(location.direction_to(enemy_location))
		enemy_hitpoints.append(current_enemy.hitpoints)
		enemy_position_differences.append(location - enemy_location)

func _on_timer_left_timeout() -> void:
	player.left_pressed = false
	if not player.right_pressed:
		is_moving = false

func _on_timer_right_timeout() -> void:
	player.right_pressed = false
	if not player.left_pressed:
		is_moving = false

func _on_timer_up_timeout() -> void:
	player.up_pressed = false
	

func _on_timer_down_timeout() -> void:
	player.down_pressed = false

func _on_timer_down_spacing_timeout() -> void:
	player_press_direction(Directions.Down)
	$TimerDownSpacing.start(random_t() * 4)

func _on_timer_chosen_enemy_timeout() -> void:
	chosen_enemy = randi_range(0, len(enemies)-1)
	var chosen_enemy_obj : PlayerCharacter = GameInfos.players[enemy_ids[chosen_enemy]]
	var fail_counter := 0
	while (not chosen_enemy_obj.alive) or (chosen_enemy_obj.team == player.team):
		chosen_enemy += 1
		fail_counter += 1
		if chosen_enemy >= enemies.size():
			chosen_enemy = 0
		chosen_enemy_obj = GameInfos.players[enemy_ids[chosen_enemy]]
		if fail_counter > 4:
			chosen_enemy = 0
			break
	$TimerChosenEnemy.start(randf_range(min_time_chosen_enemy, min_time_chosen_enemy*3))




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
