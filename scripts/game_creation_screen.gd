extends Control
class_name GameCreationScreen

const LEVEL_TITLES : Array[String] = [
	"DEFAULT",
	"Plat",
	"Boucle"
]
const MUSIC_NAMES : Array[String] = [
	"Secret Knowledge"
]
const GAME_MODE_TITLES : Array[String] = [
	"BRAWL"
]
const GAME_MODE_DESCRIPTIONS : Array[String] = [
	"BRAWL_DESCRIPTION"
]
const MUSICS_PATHS : Array[String] = [
	"res://resources/audio/music/Secret_Knowledge.wav"
]
const PLAYER_INFOS_RES := preload("res://scenes/Menus/GameCreation/PlayerSelection.tscn")
const PLAYER_INFOS_POS_OFFSET := Vector2(35.0, 75.0)
const PLAYER_INFOS_POS_INIT := Vector2(50.0, 100.0)
const DEFAULT_PLAYER := preload("res://scenes/Characters/Evolutions/ceo_character.tscn")
const WORLD_PATH := "res://scenes/world.tscn"

@export var transition : ScreenTransition

@onready var music_tester := $ButtonTestMusic/AudioTestMusic
@onready var music_background := $AudioStreamPlayer
var music_tester_music := -1
var keyboards: Array[int] = []
var controllers: Array[int] = []
var player_selectors : Array[PlayerSelection] = []

func _ready():
	GameInfos.reset_game_infos()
	set_game_widgets()
	transition.end_screen_transition()
	if GameInfos.players_data.keys().size() != 0:
		reload_old_game_infos()

func set_game_widgets():
	$GameModeSelector.options = GAME_MODE_TITLES
	$GameModeSelector.selected_option = 0
	$LevelSelector.options = LEVEL_TITLES
	$LevelSelector.selected_option = 0
	$MusicSelector.options = MUSIC_NAMES
	$MusicSelector.selected_option = 0
	set_gamemode(GameInfos.selected_gamemode)
	set_music(GameInfos.selected_music)
	set_level(GameInfos.selected_level)

func reload_old_game_infos():
	for id: int in GameInfos.players_data.keys():
		var player : PlayerCharacter = DEFAULT_PLAYER.instantiate()
		player.player_ID = id
		var control_device : int = GameInfos.players_data[id]["control_device"]
		var control_type : int = GameInfos.players_data[id]["control_type"]
		player.control_device = control_device
		player.control_type = control_type
		if control_type == 0:
			keyboards.append(control_device)
		else:
			controllers.append(control_device)
		GameInfos.players[id] = player
		create_player_infos(id)

func create_player_infos(index : int):
	var player_infos : PlayerSelection = PLAYER_INFOS_RES.instantiate()
	$PlayersContainer.add_child(player_infos)
	player_selectors.append(player_infos)
	player_infos.player_index = index
	player_infos.last_winner = (index == GameInfos.last_winner)
	player_infos.control_type = GameInfos.players_data[index]["control_type"]
	player_infos.control_index = GameInfos.players_data[index]["control_device"]
	player_infos.position = PLAYER_INFOS_POS_INIT + PLAYER_INFOS_POS_OFFSET*(
		player_selectors.size()-1)
	player_infos.connect("player_removed", remove_player)

func add_player(device_type : int, device : int):
	var player : PlayerCharacter = DEFAULT_PLAYER.instantiate()
	var player_index := player.player_ID
	player.control_device = device
	player.control_type = device_type
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

func set_test_music(test_music : bool):
	if test_music:
		music_background.stream_paused = true
		if music_tester_music != GameInfos.selected_music:
			music_tester.stream = load(MUSICS_PATHS[GameInfos.selected_music])
			music_tester.play()
		music_tester.stream_paused = false
	else:
		music_background.stream_paused = false
		music_tester.stream_paused = true

func _on_button_test_music_pressed():
	set_test_music(not music_tester.playing)

func _on_music_selector_option_changed(new_option : int):
	set_music(new_option)

func set_music(music : int):
	$ButtonTestMusic.text = MUSIC_NAMES[music]
	GameInfos.selected_music = music

func _on_game_mode_selector_option_changed(new_option : int):
	set_gamemode(new_option)

func set_gamemode(gamemode : int):
	$LabelGameModeName.text = GAME_MODE_TITLES[gamemode]
	$LabelGameModeDescription.text = GAME_MODE_DESCRIPTIONS[gamemode]

func _on_level_selector_option_changed(new_option : int):
	set_level(new_option)

func set_level(level : int):
	print("TODO : set level icon system in game_creation_screen")

func remove_player(selector : PlayerSelection, _index : int):
	var pos_in_array := player_selectors.find(selector)
	var duration := 0.3
	var tween := create_tween().set_parallel()
	if selector.control_type:
		controllers.erase(selector.control_index)
	else:
		keyboards.erase(selector.control_index)
	for i in range(pos_in_array+1, player_selectors.size()):
		var s : PlayerSelection = player_selectors[i]
		tween.tween_property(s, "position", s.position - PLAYER_INFOS_POS_OFFSET, duration)
		duration += 0.2
	player_selectors.remove_at(pos_in_array)

func _on_button_confirm_pressed():
	transition.start_screen_transition()
	await transition.HalfScreenTransitionFinished
	get_tree().change_scene_to_file(WORLD_PATH)

func _on_button_back_pressed():
	transition.start_screen_transition()
	await transition.HalfScreenTransitionFinished
	get_tree().change_scene_to_file("res://scenes/Menus/MenuPersistent.tscn")
