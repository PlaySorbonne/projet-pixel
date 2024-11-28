extends CanvasLayer
class_name GameHud

const PLAYER_PORTRAIT = preload("res://scenes/Menus/GameUI/player_portrait.tscn")

func remove_portraits() -> void:
	var t := create_tween().set_ease(Tween.EASE_IN)
	t.tween_property($HBox, "position", Vector2(0.0, 1300), 1.0)

func add_players():
	var hud_objects : Array = []
	for p : PlayerCharacter in GameInfos.players.values():
		var portrait : PlayerPortrait = PLAYER_PORTRAIT.instantiate()
		$HBox.add_child(portrait)
		portrait.initialize_portrait(p.player_ID)
		hud_objects.append(portrait)
	return hud_objects
