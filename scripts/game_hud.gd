extends CanvasLayer
class_name GameHud

const PLAYER_PORTRAIT = preload("res://scenes/Menus/GameUI/player_portrait.tscn")


func add_players():
	var hud_objects : Array = []
	for p : PlayerCharacter in GameInfos.players:
		var portrait : PlayerPortrait = PLAYER_PORTRAIT.instantiate()
		$HBox.add_child(portrait)
		portrait.initialize_portrait(p.player_ID)
		hud_objects.append(portrait)
	return hud_objects
