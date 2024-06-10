extends Node2D



func _on_area_2d_body_entered(body):
	if not body.has_method("hit"):
		return
	var player_body : PlayerCharacter = body
	if player_body.can_evolve and player_body.current_evolution == PlayerCharacter.Evolutions.Weeb:
		get_tree().change_scene_to_file("res://scenes/Menus/MenuPersistent.tscn")
	else:
		player_body.hit(1000, null)

