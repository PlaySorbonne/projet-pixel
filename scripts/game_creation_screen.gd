extends Control
class_name GameCreationScreen

const MUSICS_PATHS = [
	"res://resources/audio/music/Secret_Knowledge.wav"
]
const PLAYER_INFOS_RES = preload("res://scenes/Menus/GameCreation/PlayerSelection.tscn")
const PLAYER_INFOS_POS_OFFSET = Vector2(35.0, 75.0)
const PLAYER_INFOS_POS_INIT = Vector2(50.0, 100.0)
const DEFAULT_PLAYER := preload("res://scenes/Characters/Evolutions/ceo_character.tscn")
const WORLD_PATH = "res://scenes/world.tscn"

@export var transition : ScreenTransition

@onready var music_tester := $ButtonTestMusic/AudioTestMusic
@onready var music_background := $AudioStreamPlayer
var music_tester_music := -1
var num_player_infos := 0
var keyboards: Array[int] = []
var controllers: Array[int] = []

func _ready():
	GameInfos.reset_game_infos()
	transition.end_screen_transition()
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
	$PlayersContainer.add_child(player_infos)
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
	$ButtonTestMusic.text = $MusicSelector.get_text()
	GameInfos.selected_music = new_option

func _on_button_confirm_pressed():
	transition.start_screen_transition()
	await transition.HalfScreenTransitionFinished
	get_tree().change_scene_to_file(WORLD_PATH)


func _on_button_back_pressed():
	pass # Replace with function body.
