extends Node

enum VictoryConditions {Elimination, Kills, CassetteTime, KillBoss}

const LEVEL_PATHS : Array[String] = [
	"res://scenes/World/Levels/level_default.tscn",
	"res://scenes/World/Levels/level_high_ground.tscn",
	"res://scenes/World/Levels/level_training.tscn",
	"res://scenes/World/Levels/level_stat_editor.tscn",
	"res://scenes/World/Levels/tutorial.tscn"
]
const LEVEL_TITLES : Array[String] = [
	"DEFAULT",
	"HIGH GROUND",
	"TRAINING",
	"STAT_EDITOR"
]
var LEVEL_STAT_EDITOR : int = LEVEL_TITLES.find("STAT_EDITOR")
const MUSIC_NAMES : Array[String] = [
	"Secret Knowledge",
	"Energy",
	"Menu Theme"
]
const GAME_MODE_TITLES : Array[String] = [
	"BRAWL",
	"example gamemode"
]
const GAME_MODE_DESCRIPTIONS : Array[String] = [
	"BRAWL_DESCRIPTION",
	"example description\nhey\nexample description"
]
const MUSICS_PATHS : Array[String] = [
	"res://resources/audio/music/Secret_Knowledge.wav",
	"res://resources/audio/music/Energy.mp3",
	"res://resources/audio/music/Menu_Theme.mp3"
]
const DEFAULT_PLAYER_COLORS : Array[Color] = [
	Color.DARK_GREEN,
	Color.GOLDENROD,
	Color.TEAL,
	Color.PURPLE,
	Color.YELLOW,
	Color.LIME_GREEN,
	Color.RED,
	Color.CORNFLOWER_BLUE
]
const DEFAULT_PLAYER_NAMES : Array[String] = [
	"Luffi",
	"Quirito",
	"Gocou",
	"Naroto",
	"Saské",
	"Yu-gai",
	"Ishigo",
	"Edvard",
	"Eran",
	"Lite",
	"Découp",
	"Hasagi",
	"Gan",
	"Tinjinro",
	"Lelech",
	"Satama",
	"Ach"
]

#[
	#"Player4",
	#"Player3",
	#"Player2",
	#"Player1"
#]

var game_started := false
var player_portaits : Dictionary = {}
var world : Node2D
var camera : WorldCamera
var gameplay_timer : GameplayTimer
var camera_utils : CameraUtils
var freeze_frame : FreezeFrame
var players : Dictionary = {}
var use_special_gameplay_data := false
var tracked_targets : Array[Node2D] = []
var anime_box : AnimeBox = null
var menu_music_time := 0.0
var end_screen : EndScreen = null

var available_player_names : Array[String] = []
var available_player_colors : Array[Color] = []
var selected_gamemode : int = 0
var selected_level : int = 0
var selected_music : int = 0
var players_data : Dictionary = {}
var last_winners : Array[int] = []

var time_limit := -1
var lives_limit := -1
var victory_condition : VictoryConditions = VictoryConditions.Elimination

func format_money_string(val : int) -> String:
	var strval : String = str(val).pad_zeros(7)
	var current_char : int = strval.length() - 3
	while current_char >= 0:
		strval = strval.insert(current_char, " ")
		current_char -= 3
	return strval

func reset_game_infos(_deep_reset := false) -> void:
	end_screen = null
	game_started = false
	tracked_targets = []
	player_portaits = {}
	players = {}
	anime_box = null
	CharacterPointer.current_z = 0

func perform_deep_reset():
	reset_game_infos()
	# game mode stuff
	victory_condition = VictoryConditions.Elimination
	lives_limit = -1
	time_limit = -1.0
	# player stuff
	players_data = {}
	available_player_names = DEFAULT_PLAYER_NAMES.duplicate()
	available_player_names.shuffle()
	available_player_colors = DEFAULT_PLAYER_COLORS.duplicate()
	selected_music = 0
	selected_level = 0
	selected_gamemode = 0
	last_winners = []

func load_game_level() -> Level:
	return load(LEVEL_PATHS[selected_level]).instantiate()

func add_player(player: PlayerCharacter) -> void:
	players[player.player_ID] = player
	var p_name : String = available_player_names.pop_back()
	var p_color : Color = available_player_colors.pop_back()
	players_data[player.player_ID] = {
		"name": p_name,
		"original_name" : p_name,
		"color" : p_color,
		"original_color" : p_color,
		"last_winner" : false,
		"control_type" : player.control_type,
		"control_device" : player.control_device,
		"player_controlled" : player.is_player_controlled,
		"ai_difficulty" : player.ai_difficulty
	}

func remove_player(id : int) -> void:
	var player : PlayerCharacter = players[id]
	available_player_colors.append(players_data[id]["original_color"])
	available_player_names.append(players_data[id]["original_name"])
	players.erase(id)
	players_data.erase(id)
	if last_winners.has(id):
		last_winners.erase(id)
	if player != null:
		player.queue_free()


func players_number():
	return len(players)


# add battle type (team, brawl, etc)
