extends AI_Inputs
class_name AI_InputsCEO

const CHARGE_MAX_Y_OFFSET := 20.0
const ATTACK_RADIUS := 35.0*35.0


func _process(delta: float) -> void:
	update_enemies(delta, false)
	
	var closest_enemy : int = 0
	var smallest_dist : float = enemy_distances[0]
	for i in range(enemies.size()):
		# check if enemies are aligned for a special
		if time_since_special > time_between_specials:
			var pos_diff : Vector2 = enemy_position_differences[i]
			if abs(pos_diff.y) < CHARGE_MAX_Y_OFFSET:
				if player.facing_right:
					if pos_diff.x < 0.0:
						player_special()
						return
				elif pos_diff.x > 0.0:
					player_special()
					return
		# compute smallest_dist
		if enemy_distances[i] < smallest_dist:
			closest_enemy = i
			smallest_dist = enemy_distances[i]
	# attack closest enemy
	if time_since_attack > time_between_attacks:
		if player.facing_right:
			if enemy_position_differences[closest_enemy].x > 0.0:
				player_attack()
				return
		elif enemy_position_differences[closest_enemy].x < 0.0:
			player_attack()
			return
	else:
		if enemy_position_differences[closest_enemy].x > 0.0:
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
