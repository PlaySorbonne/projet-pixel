extends AI_Inputs
class_name AI_InputsWeeb

const CHARGE_MAX_Y_OFFSET := 70.0

func _process(delta: float) -> void:
	update_enemies(delta, false)
	# check if enemies are aligned for a special
	for i in range(enemies.size()):
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
	# attack chosen enemy
	attack_enemy()
