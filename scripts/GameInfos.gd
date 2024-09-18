extends Node

enum Levels {Default, Training, StatEditor}
const LEVEL_PATHS = {
	Levels.Default : "res://scenes/World/Levels/level_default.tscn",
	Levels.Training : "res://scenes/World/Levels/level_training.tscn",
	Levels.StatEditor : "res://scenes/World/Levels/level_stat_editor.tscn"
}

var game_started := false
var world : Node2D
var level := Levels.Default
var camera : WorldCamera
var camera_utils : CameraUtils
var freeze_frame : FreezeFrame
var players : Array[PlayerCharacter] = []
var players_order : Array[int] = []
var player_colors : Array[Color] = []
var player_names : Array[String] = []
var available_colors_index := 0
var use_special_gameplay_data := false
var tracked_targets : Array[Node2D] = []

func reset_game_infos(deep_reset := false) -> void:
	game_started = false
	tracked_targets = []
	players = []
	players_order = []
	available_colors_index = 0
	level = Levels.Default
	CharacterPointer.current_z = 0
	if deep_reset:
		player_colors = []
		player_names = []

func load_game_level() -> Level:
	return load(LEVEL_PATHS[level]).instantiate()

func add_player(player: PlayerCharacter) -> void:
	players.append(player)
	player_colors.append(available_colors()[0])
	
func remove_player(player: PlayerCharacter) -> void:
	var id = player.player_ID
	players.remove_at(id)
	player_colors.remove_at(id)
	compute_ids()

func compute_ids() -> void:
	for i in range(len(players)):
		players[i].player_ID = i
		players[i]._update_debug_text()
		
func available_colors() -> Array:
	return PlayerCharacter.PLAYER_COLORS.filter(func(c): return not c in player_colors)
	
func change_color(player_id: int) -> void:
	var available_colors = available_colors()
	player_colors[player_id] = available_colors[available_colors_index]
	available_colors_index += 1
	if available_colors_index == len(available_colors):
		available_colors_index = 0

func players_number(): return len(players)

# add stats (damage, kills, deaths, time in the air, time on the ground, distance, 
# accuracy, evolution...)


# add battle type (team, brawl, etc)
