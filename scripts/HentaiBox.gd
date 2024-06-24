extends Node2D

signal game_won

func _on_area_2d_body_entered(body):
	if not body.has_method("hit"):
		return
	var player_body : PlayerCharacter = body
	if player_body.current_evolution == PlayerCharacter.Evolutions.Weeb:
		emit_signal("game_won")
	#else:
	#	player_body.hit(1000, null)
