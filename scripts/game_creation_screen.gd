extends Control
class_name GameCreationScreen

const PLAYER_INFOS_RES = preload("res://scenes/Menus/GameCreation/PlayerSelection.tscn")
const PLAYER_INFOS_POS_OFFSET = Vector2(35.0, 75.0)
const PLAYER_INFOS_POS_INIT = Vector2(50.0, 100.0)
const DEFAULT_PLAYER := preload("res://scenes/Characters/Evolutions/ceo_character.tscn")

var num_player_infos := 0
var keyboards: Array[int] = []
var controllers: Array[int] = []

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
	if index == GameInfos.last_winner:
		player_infos.last_winner = true
	player_infos.position = PLAYER_INFOS_POS_INIT + PLAYER_INFOS_POS_OFFSET*num_player_infos
	$LabelPlayers.add_child(player_infos)
	num_player_infos += 1

func add_player(device_type : int, device : int):
	var is_keyboard = (device_type == 0)
	var player_index := GameInfos.player_names.size()
	GameInfos.player_names.append("Player" + str(player_index + 1))
	GameInfos.player_colors.append(PlayerCharacter.PLAYER_COLORS[player_index])
	var player = DEFAULT_PLAYER.instantiate()
	player.control_device = device
	player.control_type = device_type
	player.god_mode = true
	GameInfos.add_player(player)
	create_player_infos(player_index)

func _input(event):
	if event is InputEventKey:
		if event.device not in keyboards:
			if event.is_pressed():
				keyboards.append(event.device)
				add_player(0, event.device)
	elif event is InputEventJoypadButton:
		if event.device not in controllers:
			if event.is_pressed():
				controllers.append(event.device)
				add_player(1, event.device)
