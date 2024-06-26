extends CanvasLayer
class_name GameHud

const PLAYER_PORTRAIT = preload("res://scenes/Menus/GameUI/player_portrait.tscn")


func add_players():
	for p : PlayerCharacter in GameInfos.players:
		var portrait : PlayerPortrait = PLAYER_PORTRAIT.instantiate()
		$HBox.add_child(portrait)
		portrait.initialize_portrait(p.player_ID)
