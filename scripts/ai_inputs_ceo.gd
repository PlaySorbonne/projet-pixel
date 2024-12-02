extends AI_Inputs
class_name AI_InputsCEO

const CHARGE_MAX_Y_OFFSET := 20.0


func _process(delta: float) -> void:
	update_enemies(delta, false)
	
	for i in range(enemies.size()):
		var pos_diff : Vector2 = enemy_position_differences[i]
		if abs(pos_diff.y) < CHARGE_MAX_Y_OFFSET:
			if player.facing_right:
				if 
			player.special()



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
