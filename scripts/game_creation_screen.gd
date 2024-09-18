extends Control
class_name GameCreationScreen

const PLAYER_INFOS_RES = preload("res://scenes/Menus/GameCreation/PlayerSelection.tscn")
const PLAYER_INFOS_POS_OFFSET = Vector2(35.0, 75.0)
const PLAYER_INFOS_POS_INIT = Vector2(50.0, 100.0)

var num_player_infos := 0

func _ready():
	GameInfos.reset_game_infos()
	if GameInfos.player_names.size() != 0:
		reload_old_game_infos()

func reload_old_game_infos():
	for i : int in range(len(GameInfos.player_names)):
		create_player_infos(i)

func create_player_infos(index : int):
	var player_infos : PlayerSelection = PLAYER_INFOS_RES.instantiate()
	player_infos.player_index = index
	player_infos.position = PLAYER_INFOS_POS_INIT + PLAYER_INFOS_POS_OFFSET*num_player_infos
	$LabelPlayers.add_child(player_infos)
	num_player_infos += 1
