extends AI_Inputs
class_name AI_InputsEmployee

const SPECIAL_MAX_X_OFFSET := 50.0

func _process(delta: float) -> void:
	update_enemies(delta, false)
	# check if enemies are close enough for a special
	for i in range(enemies.size()):
		if time_since_special > time_between_specials:
			var pos_diff : Vector2 = enemy_position_differences[i]
			if abs(pos_diff.x) < SPECIAL_MAX_X_OFFSET:
				player_special()
				return
	# attack chosen enemy
	attack_enemy()
