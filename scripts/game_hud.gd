extends CanvasLayer

const PLAYER_PORTRAIT = preload("res://scenes/Menus/GameUI/player_portrait.tscn")

func _ready():
	pass

func add_players():
	for p in GameInfos.players:
		var portrait : PlayerPortrait = PLAYER_PORTRAIT.instantiate()
		$HBox.add_child(portrait)
